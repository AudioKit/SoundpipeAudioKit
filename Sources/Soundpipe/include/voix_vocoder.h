#ifndef voix_vocoder_h
#define voix_vocoder_h

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include "soundpipe.h"
#include "Yin.h"
#include "circular_buffer.h"

typedef struct {
    sp_vocoder *voc;
    sp_blsquare *square[3];
    Yin *yin;
    circular_buffer *buff;
    sp_moogladder *lpf;
    int16_t *intBuffer;
    int nearest_scale_freq_index;
    float f_nearest_scale_freq_index;
} voix_vocoder;

int voix_vocoder_create(voix_vocoder **p);
int voix_vocoder_init(sp_data *sp, voix_vocoder *p);
int voix_vocoder_compute(sp_data *sp, voix_vocoder *p, float rms, float *in, float *out);
int vocoder_set_scale_freqs(float *frequencies, int count);

#endif /* voix_vocoder_h */
