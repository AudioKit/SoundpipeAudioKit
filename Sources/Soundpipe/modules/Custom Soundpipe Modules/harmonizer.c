#include "harmonizer.h"

#define max(a,b) ((a < b) ? b : a)
#define min(a,b) ((a < b) ? a : b)

float *harmonizer_scale_freqs;
int harmonizer_scale_freqs_count = 0;

int harmonizer_create(harmonizer **p) {
    *p = malloc(sizeof(harmonizer));
    return SP_OK;
}

int harmonizer_init(sp_data *sp, harmonizer *p) {
    smbpitchshift_create(&p->pshift1);
    smbpitchshift_create(&p->pshift2);
    smbpitchshift_create(&p->pshift3);
    smbpitchshift_create(&p->pshift4);

    smbpitchshift_init(p->pshift1, 1024, 8, sp->sr);
    smbpitchshift_init(p->pshift2, 1024, 8, sp->sr);
    smbpitchshift_init(p->pshift3, 1024, 8, sp->sr);
    smbpitchshift_init(p->pshift4, 1024, 8, sp->sr);

    p->mode = 0;
    p->num_harmonies = 4;
    return SP_OK;
}

float harmonizer_semitone_ratio(float freq1, float freq2) {
    float semitones = 12.0 * log2f(freq1 / freq2);
    return semitones;
}

int harmonizer_compute(sp_data *sp, harmonizer *p, float *in, int scale_freq_index, float *out) {
    if (scale_freq_index == -1) {
        *out = *in;
        return SP_NOT_OK;
    }

    float pshift1_out = 0.0;
    float pshift2_out = 0.0;
    float pshift3_out = 0.0;

    switch (p->mode) {
        case 0: // 4th and 6th below
            if (scale_freq_index - 3 >= 0) {
                float shift = harmonizer_scale_freqs[scale_freq_index - 3] / harmonizer_scale_freqs[scale_freq_index];
                smbpitchshift_compute(p->pshift1, shift, 1, in, &pshift1_out);
            }
            if (scale_freq_index - 5 >= 0) {
                float shift = harmonizer_scale_freqs[scale_freq_index - 5] / harmonizer_scale_freqs[scale_freq_index];
                smbpitchshift_compute(p->pshift2, shift, 1, in, &pshift2_out);
            }
            break;
        case 1: // traid above
            if (scale_freq_index + 2 < harmonizer_scale_freqs_count) {
                float shift = harmonizer_scale_freqs[scale_freq_index + 2] / harmonizer_scale_freqs[scale_freq_index];
                smbpitchshift_compute(p->pshift1, shift, 1, in, &pshift1_out);
            }
            if (scale_freq_index + 4 < harmonizer_scale_freqs_count) {
                float shift = harmonizer_scale_freqs[scale_freq_index + 4] / harmonizer_scale_freqs[scale_freq_index];
                smbpitchshift_compute(p->pshift2, shift, 1, in, &pshift2_out);
            }
            break;
        case 2: // 7th chord above
            if (scale_freq_index + 2 < harmonizer_scale_freqs_count) {
                float shift = harmonizer_scale_freqs[scale_freq_index + 2] / harmonizer_scale_freqs[scale_freq_index];
                smbpitchshift_compute(p->pshift1, shift, 1, in, &pshift1_out);
            }
            if (scale_freq_index + 4 < harmonizer_scale_freqs_count) {
                float shift = harmonizer_scale_freqs[scale_freq_index + 4] / harmonizer_scale_freqs[scale_freq_index];
                smbpitchshift_compute(p->pshift2, shift, 1, in, &pshift2_out);
            }
            if (scale_freq_index + 6 < harmonizer_scale_freqs_count) {
                float shift = harmonizer_scale_freqs[scale_freq_index + 6] / harmonizer_scale_freqs[scale_freq_index];
                smbpitchshift_compute(p->pshift3, shift, 1, in, &pshift3_out);
            }
            break;
        case 3: // 3rd above and an octave below
            smbpitchshift_compute(p->pshift1, 0.5, 1, in, &pshift1_out);
            if (scale_freq_index + 2 < harmonizer_scale_freqs_count) {
                float shift = harmonizer_scale_freqs[scale_freq_index + 2] / harmonizer_scale_freqs[scale_freq_index];
                smbpitchshift_compute(p->pshift2, shift, 1, in, &pshift2_out);
            }
            break;
        case 4: // octave above and below
            smbpitchshift_compute(p->pshift1, 2.0, 1, in, &pshift1_out);
            smbpitchshift_compute(p->pshift2, 0.5, 1, in, &pshift2_out);
            break;
        case 5: // fifth above
            smbpitchshift_compute(p->pshift1, 1.5, 1, in, &pshift1_out);
            break;
        default:
            break;
    }

    *out = *in + pshift1_out + pshift2_out + pshift3_out;
    return SP_OK;
}

int harmonizer_set_scale_freqs(float *frequencies, int count) {
    harmonizer_scale_freqs = malloc(sizeof(float) * count);
    memcpy(harmonizer_scale_freqs, frequencies, sizeof(float) * count);
    harmonizer_scale_freqs_count = count;
    return SP_OK;
}
