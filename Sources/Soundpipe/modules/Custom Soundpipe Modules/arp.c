#include "arp.h"

int arp_create(arp **p) {
    *p = malloc(sizeof(arp));
    return SP_OK;
}

int arp_init(sp_data *sp, arp *p) {
    p->num_steps = 15;
    p->dels = malloc(sizeof(sp_delay) * p->num_steps);
    p->pshifts = malloc(sizeof(sp_pshift) * p->num_steps);

    float t = 0.08;
    for (int i = 0; i < p->num_steps; i++) {
        sp_delay_init(sp, &p->dels[i], t * (float)(i + 1));
        sp_pshift_init(sp, &p->pshifts[i]);
        *p->pshifts[i].window = 1750.0;
        *p->pshifts[i].xfade = 1750.0;
    }

    return SP_OK;
}

int arp_compute(sp_data *sp, arp *p, float *in, float autotune_freq, float *out) {
    float del_out = 0.0;
    float pshift_out = 0.0;

    *out = *in;

    float steps[4] = { 4, 7, 11, 12 };

    for (int i = 0; i < p->num_steps; i++) {
        sp_delay_compute(sp, &p->dels[i], in, &del_out);
        if (del_out != 0.0) {
            if (autotune_freq > 0) {
                *p->pshifts[i].window = (1.0 / autotune_freq) * (float)sp->sr;
                *p->pshifts[i].xfade = *p->pshifts[i].window / 2.0f;
            }

            int mult = (i / 4);
            *p->pshifts[i].shift = steps[i % 4] + (12 * (float)mult);
            sp_pshift_compute(sp, &p->pshifts[i], &del_out, &pshift_out);

            float gain = 1.0 - ((float)i / (float)p->num_steps);
            *out += (pshift_out * powf(gain, 2));
        }

        del_out = 0.0;
        pshift_out = 0.0;
    }

    return SP_OK;
}
