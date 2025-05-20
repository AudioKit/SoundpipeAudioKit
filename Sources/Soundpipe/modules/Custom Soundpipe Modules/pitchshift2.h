#ifndef pitchshift2_h
#define pitchshift2_h

#include <stdio.h>
#include "soundpipe.h"
#include "circular_buffer.h"

typedef struct pitchshift2 {
    circular_buffer *buff;
    sp_buthp *hpf;
    float playhead_idx;
    float window;
    float fader;
    float min_freq;
    float max_freq;
} pitchshift2;

int pitchshift2_create(pitchshift2 **p);
int pitchshift2_init(sp_data *sp, pitchshift2 *p, float min_freq, float max_freq);
int pitchshift2_compute(sp_data *sp, pitchshift2 *p, float base_freq, float freq_ratio, float *in, float *out);

#endif /* pitchshift2_h */
