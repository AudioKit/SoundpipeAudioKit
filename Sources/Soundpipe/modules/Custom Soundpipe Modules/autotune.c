#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "autotune.h"
#include "Yin.h"
#include "circular_buffer.h"

#define max(a,b) ((a < b) ? b : a)
#define min(a,b) ((a < b) ? a : b)

float min_freq = 20.0;
float max_freq = 3000.0;

int autotune_create(autotune **p) {
    *p = malloc(sizeof(autotune));
    return SP_OK;
}

int autotune_init(sp_data *sp, autotune *p) {
    pitchshift2_create(&p->pshift2);
    pitchshift2_init(sp, p->pshift2, min_freq, max_freq);
    pitchcalculate_create(&p->pcalc);
    pitchcalculate_init(sp, p->pcalc, min_freq, max_freq);
    sp_butlp_create(&p->lpf);
    sp_butlp_init(sp, p->lpf);
    sp_port_create(&p->scale_freq_port);
    sp_port_init(sp, p->scale_freq_port, 0.0);
    p->base_freq = 200.0;
    p->pshift_freq_ratio = 1.0f;
    p->cur_correction_amt_cents = 0.0f;
    p->nearest_scale_freq = -1.0f;
    p->lpf->freq = 4000.;
    p->yin = malloc(sizeof(Yin));
    Yin_init(p->yin, 128, 0.15, sp->sr);
    p->yin_downsample_acc = 0;
    p->intBuffer = malloc(sizeof(int16_t) * p->yin->bufferSize);
    p->buff = malloc(sizeof(circular_buffer));
    cb_init(p->buff, 4096, sizeof(int16_t));
    p->correction_mode_active = false;
    p->scale_freq_index_acc = 0;
    p->unknown_freq_acc = 0;
    p->detected_freq = 10000;
    p->cur_freq_ratio = -1;
    p->amount = 1.0f;
    p->speed = 1.0f;
    return SP_OK;
}

float nearest_scale_freq_index(autotune *p, float freq) {
    if (freq < 0) {
        return 0.0;
    }

    float nearest_difference = 10000.0;
    float nearest = 10.0;
    float nearest_index = -1;
    for (int i = 0; i < p->autotune_scale_freqs_count; i++) {
        float diff = fabs(p->autotune_scale_freqs[i] - freq);
        if (diff < nearest_difference) {
            nearest_difference = diff;
            nearest = p->autotune_scale_freqs[i];
            nearest_index = (float)i;
        } else if (diff > nearest_difference) {
            break;
        }
    }

    return nearest_index;
}

float semitone_ratio(float scale_freq, float detected_freq) {
    float ratio = max(scale_freq, detected_freq) / min(scale_freq, detected_freq);
    if (ratio < 2.5) {
        float semitones = 12.0 * log2f(scale_freq / detected_freq);
        return semitones;
    }

    return 1.0;
}

int yin_add_to_buff(sp_data *sp, autotune *p, float *in) {
    float lpf_out;
    sp_butlp_compute(sp, p->lpf, in, &lpf_out);

    if (p->yin_downsample_acc >= 7) {
        int16_t intIn = (int16_t)(lpf_out * 32767.0);
        cb_push_back(p->buff, &intIn);
        p->yin_downsample_acc = 0;
    } else {
        p->yin_downsample_acc++;
    }

    return SP_OK;
}

int compute_yin_pitch(sp_data *sp, autotune *p) {
    if (p->buff->count >= p->yin->bufferSize) {
        cb_pop_multiple(p->buff, p->intBuffer, p->yin->bufferSize, 16);
        float freq = Yin_getPitch(p->yin, p->intBuffer);

        if (freq > min_freq && freq < max_freq && p->yin->probability >= 0.95) {
            p->detected_freq = freq;
//            printf("%f %f\n", freq, p->nearest_scale_freq_index);
        } else {
            p->should_smooth_scale_idx = false;
            p->detected_freq = -1;
//            printf("below prob\n");
        }
    }

    return SP_OK;
}

int compute_nearest_scale_freq_index(sp_data *sp, autotune *p) {
    p->scale_freq_index_acc++;

    float freq = p->detected_freq;
    if (freq < min_freq || freq > max_freq) {
        return SP_OK;
    }

    if (p->scale_freq_index_acc >= 128) {
        p->scale_freq_index_acc = 0;

        if (p->should_smooth_scale_idx) {
            p->nearest_scale_freq_index = (nearest_scale_freq_index(p, freq) * 0.1) + (p->nearest_scale_freq_index * 0.9);
        } else {
            p->nearest_scale_freq_index = nearest_scale_freq_index(p, freq);
            p->should_smooth_scale_idx = true;
        }

        int integerScaleIndex = (int)roundf(p->nearest_scale_freq_index);
        if (integerScaleIndex >= 0 && integerScaleIndex < p->autotune_scale_freqs_count) {
            p->target_freq = p->autotune_scale_freqs[integerScaleIndex];
        }
    }

    float smooth_target_freq;

    if (!p->should_smooth_target_freq) {
        sp_port_reset(sp, p->scale_freq_port, &p->target_freq);
        p->should_smooth_target_freq = true;
    }
    sp_port_compute(sp, p->scale_freq_port, &p->target_freq, &smooth_target_freq);

    float new_freq_ratio = smooth_target_freq / freq;
    p->cur_freq_ratio = (new_freq_ratio * p->amount) + (1 - p->amount);
    p->nearest_scale_freq = smooth_target_freq;

    float new_correction_amt = semitone_ratio(smooth_target_freq, freq) * 100.0f * p->amount;
    p->cur_correction_amt_cents = p->cur_correction_amt_cents * 0.99 + new_correction_amt * 0.01;

    return SP_OK;
}

int autotune_compute(sp_data *sp, autotune *p, float *in, float *out, float rms) {
    if (p->should_update_scale_freqs) {
        p->autotune_scale_freqs = p->tmp_scale_freqs;
        p->autotune_scale_freqs_count = p->tmp_scale_freqs_count;
        p->should_update_scale_freqs = false;
        p->scale_freq_index_acc = 128;
        p->should_smooth_scale_idx = false;
    }

    pitchcalculate_add_to_buff(p->pcalc, in);
    yin_add_to_buff(sp, p, in);

    float pcalc_initial_freq = -1.0f;
    if (!p->correction_mode_active && rms >= 0.001) {
        // detection mode
        compute_yin_pitch(sp, p);

        if (p->detected_freq > min_freq && p->detected_freq < max_freq) {
            p->correction_mode_active = true;
            pcalc_initial_freq = p->detected_freq;
        }
    }

    if (p->correction_mode_active) {
        // correction mode
        float freq;
        int success = pitchcalculate_compute(sp, p->pcalc, pcalc_initial_freq, in, &freq);
        if (success == SP_OK) {
            p->detected_freq = freq;
        } else {
            p->correction_mode_active = false;
            p->detected_freq = -1;
        }
    }

    if (p->detected_freq != -1) {
//        printf("%f\n", p->detected_freq);
    }

//    printf("%f\n", p->detected_freq);

    if (p->detected_freq == -1) {
        p->should_smooth_scale_idx = false;
        p->unknown_freq_acc++;

        if (p->unknown_freq_acc == 4096) {
            p->should_smooth_target_freq = false;
        }
    } else {
        p->unknown_freq_acc = 0;
    }

    // find nearest scale freq index
    compute_nearest_scale_freq_index(sp, p);

    if (p->detected_freq > min_freq && p->detected_freq < max_freq) {
        p->base_freq = p->detected_freq;
    }

    if (p->cur_freq_ratio > 0.5 && p->cur_freq_ratio < 2) {
        p->pshift_freq_ratio = (p->pshift_freq_ratio * 0.8) + (p->cur_freq_ratio * 0.2);
    }

//    printf("%f\n", p->pshift_smooth);
//    sp_pshift_compute(sp, p->pshift, in, out);

    pitchshift2_compute(sp, p->pshift2, p->base_freq, p->pshift_freq_ratio, in, out);

    return SP_OK;
}

int autotune_set_scale_freqs(autotune *p, float *frequencies, int count) {
    float *new_freqs = malloc(sizeof(float) * count);
    memcpy(new_freqs, frequencies, sizeof(float) * count);
    p->tmp_scale_freqs = new_freqs;
    p->tmp_scale_freqs_count = count;
    p->should_update_scale_freqs = true;
    return SP_OK;
}

int autotune_set_amount(autotune *p, float amount) {
    p->amount = amount;
    return SP_OK;
}

int autotune_set_speed(autotune *p, float speed) {
    p->speed = speed;
    p->scale_freq_port->htime = -0.05 * speed + 0.05;
    return SP_OK;
}
