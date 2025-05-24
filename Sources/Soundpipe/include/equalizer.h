#ifndef equalizer_h
#define equalizer_h

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "soundpipe.h"

typedef struct equalizer {
    sp_eqfil *eq1;
    sp_eqfil *eq2;
    sp_eqfil *eq3;
    sp_eqfil *eq4;
} equalizer;

int equalizer_create(equalizer **eq);
int equalizer_init(sp_data *sp, equalizer *eq);
int equalizer_compute(sp_data *sp, equalizer *eq, float *in, float *out);

#endif /* equalizer_h */
