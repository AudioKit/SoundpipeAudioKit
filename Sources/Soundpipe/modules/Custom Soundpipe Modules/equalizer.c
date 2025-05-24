#include "equalizer.h"

int equalizer_create(equalizer **eq) {
    *eq = malloc(sizeof(equalizer));
    return SP_OK;
}

int equalizer_init(sp_data *sp, equalizer *eq) {
    sp_eqfil_create(&eq->eq1);
    sp_eqfil_init(sp, eq->eq1);
    sp_eqfil_create(&eq->eq2);
    sp_eqfil_init(sp, eq->eq2);
    sp_eqfil_create(&eq->eq3);
    sp_eqfil_init(sp, eq->eq3);
    sp_eqfil_create(&eq->eq4);
    sp_eqfil_init(sp, eq->eq4);

    eq->eq1->freq = 192.0f;
    eq->eq1->bw = 240.0f;
    eq->eq1->gain = 3.16f; // 5.0dB

    eq->eq2->freq = 360.0f;
    eq->eq2->bw = 220.0f;
    eq->eq2->gain = 0.02f; // -15.5dB

    eq->eq3->freq = 1320.0f;
    eq->eq3->bw = 1340.0f;
    eq->eq3->gain = 2.5f; // 4.0dB

    eq->eq4->freq = 4000.0f;
    eq->eq4->bw = 2800.0f;
    eq->eq4->gain = 0.12f; // -18.5dB

    return SP_OK;
}

int equalizer_compute(sp_data *sp, equalizer *eq, float *in, float *out) {
    float eq1_out = 0.0;
    float eq2_out = 0.0;
    float eq3_out = 0.0;
    sp_eqfil_compute(sp, eq->eq1, in, &eq1_out);
    sp_eqfil_compute(sp, eq->eq2, &eq1_out, &eq2_out);
    sp_eqfil_compute(sp, eq->eq3, &eq2_out, &eq3_out);
    sp_eqfil_compute(sp, eq->eq4, &eq3_out, out);

    return SP_OK;
}
