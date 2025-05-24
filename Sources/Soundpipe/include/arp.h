#ifndef arp_h
#define arp_h

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "soundpipe.h"
#include "pitchshift.h"

typedef struct {
    sp_delay *dels;
    sp_pshift *pshifts;
    int num_steps;
} arp;

int arp_create(arp **p);
int arp_init(sp_data *sp, arp *p);
int arp_compute(sp_data *sp, arp *p, float *in, float pitchcorrect_freq, float *out);

#endif /* arp_h */
