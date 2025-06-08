#include "pitchshift2.h"
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>
#include <stdio.h>

float delay_window = 75.;
float pi = 3.1415926535;

int pitchshift2_create(pitchshift2 **p) {
    *p = malloc(sizeof(pitchshift2));
    return SP_OK;
}

int pitchshift2_init(sp_data *sp, pitchshift2 *p, float min_freq, float max_freq) {
    p->buff = malloc(sizeof(circular_buffer));
    cb_init(p->buff, 4096, sizeof(float));
    sp_buthp_create(&p->hpf);
    sp_buthp_init(sp, p->hpf);
    p->hpf->freq = 5000.0f;
    p->playhead_idx = 0.0f;
    p->fader = 0.0f;
    p->window = 300.0f;
    p->min_freq = min_freq;
    p->max_freq = max_freq;
    return SP_OK;
}

float compute_interpolated_sample_at_index(circular_buffer *cb, float idx) {
    if (rintf(idx) == idx) {
        float *samp;
        cb_read_at_index_behind_write(cb, (int)idx, &samp);
        return *samp;
    }

    float idx2 = ceilf(idx);
    float idx3 = idx2 + 1;
    float idx1 = floorf(idx);
    float idx0 = idx1 - 1;

    float *samp0;
    float *samp1;
    float *samp2;
    float *samp3;
    cb_read_at_index_behind_write(cb, (int)idx0, &samp0);
    cb_read_at_index_behind_write(cb, (int)idx1, &samp1);
    cb_read_at_index_behind_write(cb, (int)idx2, &samp2);
    cb_read_at_index_behind_write(cb, (int)idx3, &samp3);

    // lagrange quartic polynomial interpolation
    float finalSamp = 0.0f;
    finalSamp += *samp0 * ((idx - idx1) * (idx - idx2) * (idx - idx3)) / ((idx0 - idx1) * (idx0 - idx2) * (idx0 - idx3));
    finalSamp += *samp1 * ((idx - idx0) * (idx - idx2) * (idx - idx3)) / ((idx1 - idx0) * (idx1 - idx2) * (idx1 - idx3));
    finalSamp += *samp2 * ((idx - idx0) * (idx - idx1) * (idx - idx3)) / ((idx2 - idx0) * (idx2 - idx1) * (idx2 - idx3));
    finalSamp += *samp3 * ((idx - idx0) * (idx - idx1) * (idx - idx2)) / ((idx3 - idx0) * (idx3 - idx1) * (idx3 - idx2));

    return finalSamp;
}

int pitchshift2_compute(sp_data *sp, pitchshift2 *p, float base_freq, float freq_ratio, float *in, float *out) {
    cb_push_back(p->buff, in);

//    printf("%f\n", base_freq);
//    if (base_freq <= 0 || base_freq >= p->buff->capacity) {
//        *out = *in;
//        return SP_OK;
//    }

//    printf("%f\n", freq_ratio);

    p->playhead_idx += freq_ratio - 1;
    if (p->playhead_idx > 0) {
        p->playhead_idx -= p->window;
    } else if (p->playhead_idx < (-1 * p->window)) {
        p->playhead_idx += p->window;
    }

    float crossfade = 30.0f;
    p->fader = (1.0f / crossfade) * p->playhead_idx + 1;
    if (p->fader > 1) {
        p->fader = 1;
    } else if (p->fader < 0) {
        p->fader = 0;
    }

    float samp = compute_interpolated_sample_at_index(p->buff, p->playhead_idx - 5);
    if (p->fader > 0) {
        float fadeSamp = compute_interpolated_sample_at_index(p->buff, p->playhead_idx - p->window - 5);
        float sampMix = (cosf(p->fader * pi / 2) / 2) + ((1 - p->fader) / 2);
        float fadeSampMix = (sinf(p->fader * pi / 2) / 2) + (p->fader / 2);
        *out = (samp * sampMix) + (fadeSamp * fadeSampMix);
    } else {
        *out = samp;
    }

    if (p->fader == 0 && base_freq > p->min_freq && base_freq < p->max_freq) {
        float new_window = (1.0f / base_freq) * (float)sp->sr;
        p->window = fmaxf(new_window, -1 * p->playhead_idx);
    }

//    printf("%f %f %f %f %f\n", p->fader, p->playhead_idx, freq_ratio, *out, *in);

    return SP_OK;
}
