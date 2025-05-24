#ifndef harmonizer_h
#define harmonizer_h

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "soundpipe.h"
#include "pitchshift.h"

typedef struct {
    smbpitchshift *pshift1;
    smbpitchshift *pshift2;
    smbpitchshift *pshift3;
    smbpitchshift *pshift4;
    int scale_freq_index;
    int num_harmonies;
    int mode;
} harmonizer;

int harmonizer_create(harmonizer **p);
int harmonizer_init(sp_data *sp, harmonizer *p);
int harmonizer_set_scale_freqs(float *frequencies, int count);
int harmonizer_compute(sp_data *sp, harmonizer *p, float *in, int scale_freq_index, float *out);

#endif /* harmonizer_h */
