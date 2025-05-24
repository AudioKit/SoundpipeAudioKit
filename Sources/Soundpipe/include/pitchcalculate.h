#ifndef pitchcalculate_h
#define pitchcalculate_h

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include "soundpipe.h"
#include "circular_buffer.h"

typedef struct pitchcalculate {
    circular_buffer *buff;
    int eh_offset;
    int num_offsets;
    int num_offsets_2;
    float *eil;
    float *hil;
    float *asdf;
    float asdf_offset;
    int min_period;
    int max_period;
    float min_freq;
    float max_freq;
    int iter;
    float cur_period;
    int failure_count;
} pitchcalculate;

int pitchcalculate_create(pitchcalculate **p);
int pitchcalculate_init(sp_data *sp, pitchcalculate *p, float min_freq, float max_freq);
int pitchcalculate_add_to_buff(pitchcalculate *p, float *in);
int pitchcalculate_compute(sp_data *sp, pitchcalculate *p, float initial_freq, float *in, float *output_pitch);

#endif /* pitchcalculate_h */
