#include "voix_vocoder.h"
#include <stdlib.h>
#include <math.h>
#include <string.h>

float *vocoder_scale_freqs;
int vocoder_scale_freqs_count = 0;

int voix_vocoder_create(voix_vocoder **p) {
    *p = malloc(sizeof(voix_vocoder));
    return SP_OK;
}

int voix_vocoder_init(sp_data *sp, voix_vocoder *p) {
    sp_vocoder_create(&p->voc);
    sp_vocoder_init(sp, p->voc);
    *p->voc->bwratio = 0.1f;
    *p->voc->atk = 0.0f;
    *p->voc->rel = 0.0f;

    p->yin = malloc(sizeof(Yin));
    Yin_init(p->yin, 1024, 0.15, sp->sr);
    p->intBuffer = malloc(sizeof(int16_t) * p->yin->bufferSize);

    p->buff = malloc(sizeof(circular_buffer));
    cb_init(p->buff, 4096, sizeof(int16_t));

    sp_moogladder_create(&p->lpf);
    sp_moogladder_init(sp, p->lpf);
    p->lpf->freq = 10000.;
    p->lpf->res = 0.01;

    p->nearest_scale_freq_index = 5;
    p->f_nearest_scale_freq_index = 5.0;

    int scale[] = { 60, 64, 67 };

    for(int i = 0; i < 3; i++) {
        sp_blsquare_create(&p->square[i]);
        sp_blsquare_init(sp, p->square[i]);
        *p->square[i]->freq = sp_midi2cps(scale[i]);
    }

    return SP_OK;
}

float voc_nearest_scale_freq_index(float freq) {
    if (freq < 0) {
        return 0.0;
    }

    float nearest_difference = 10000.0;
    float nearest = 10.0;
    float nearest_index = -1;
    for (int i = 0; i < vocoder_scale_freqs_count; i++) {
        float diff = fabs(vocoder_scale_freqs[i] - freq);
        if (diff < nearest_difference) {
            nearest_difference = diff;
            nearest = vocoder_scale_freqs[i];
            nearest_index = (float)i;
        } else if (diff > nearest_difference) {
            break;
        }
    }

    return nearest_index;
}

int voix_vocoder_compute(sp_data *sp, voix_vocoder *p, float rms, float *in, float *out) {
    float lpf_out;
    sp_moogladder_compute(sp, p->lpf, in, &lpf_out);

    int16_t intIn = (int16_t)(lpf_out * 32767.0);
    cb_push_back(p->buff, &intIn);

    if (p->buff->count >= p->yin->bufferSize) {
        cb_pop_multiple(p->buff, p->intBuffer, p->yin->bufferSize, 256);
        float freq = Yin_getPitch(p->yin, p->intBuffer);

        if (freq > 60 && freq < 800 && p->yin->probability >= 0.95) {
            p->f_nearest_scale_freq_index = (voc_nearest_scale_freq_index(freq) * 0.1) + (p->f_nearest_scale_freq_index * 0.9);
            p->nearest_scale_freq_index = (int)roundf(p->f_nearest_scale_freq_index);
        } else {
            // adjust gain to zero
        }
    }

    int notes[] = { -7, 0, 2 };

    float square = 0.0, tmp = 0;
    for (int i = 1; i < 2; i++) {
        if (p->nearest_scale_freq_index + notes[i] < vocoder_scale_freqs_count && p->nearest_scale_freq_index + notes[i] >= 0) {
            *p->square[i]->freq = vocoder_scale_freqs[p->nearest_scale_freq_index + notes[i]];
            sp_blsquare_compute(sp, p->square[i], NULL, &tmp);
            square += tmp;
        }
    }
//    square *= 0.2;
    if (square > 1 || square < -1) {
        printf("square %f\n", square);
    }

    sp_vocoder_compute(sp, p->voc, in, &square, out);

    if (*out > 1 || *out < -1) {
        printf("out %f\n", *out);
    }

    return SP_OK;
}

int vocoder_set_scale_freqs(float *frequencies, int count) {
    vocoder_scale_freqs = malloc(sizeof(float) * count);
    memcpy(vocoder_scale_freqs, frequencies, sizeof(float) * count);
    vocoder_scale_freqs_count = count;
    return SP_OK;
}
