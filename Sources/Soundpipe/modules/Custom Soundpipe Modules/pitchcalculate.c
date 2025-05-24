#include "pitchcalculate.h"
#include "interpolate.h"
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>
#include <stdio.h>

int pitchcalculate_create(pitchcalculate **p) {
    *p = malloc(sizeof(pitchcalculate));
    return SP_OK;
}

int pitchcalculate_init(sp_data *sp, pitchcalculate *p, float min_freq, float max_freq) {
    p->buff = malloc(sizeof(circular_buffer));
    cb_init(p->buff, 4096, sizeof(float));
    p->eh_offset = -1;
    p->num_offsets = 8;
    p->num_offsets_2 = p->num_offsets / 2;
    p->eil = malloc(sizeof(float) * (p->num_offsets + 1));
    p->hil = malloc(sizeof(float) * (p->num_offsets + 1));
    p->asdf = malloc(sizeof(float) * (p->num_offsets + 1));

    for (int i = 0; i < p->num_offsets; i++) {
        p->eil[i] = 0.0f;
        p->hil[i] = 0.0f;
        p->asdf[i] = 0.0f;
    }

    p->min_freq = min_freq;
    p->max_freq = max_freq;
    p->min_period = (int)((float)sp->sr / max_freq);
    p->max_period = (int)((float)sp->sr / min_freq);
    p->iter = 1;
    p->failure_count = 0;

    return SP_OK;
}

int pitchcalculate_add_to_buff(pitchcalculate *p, float *in) {
    cb_push_back(p->buff, in);
    return SP_OK;
}

int pitchcalculate_compute(sp_data *sp, pitchcalculate *p, float initial_freq, float *in, float *output_pitch) {
    // ----- FILL ASDF ARRAY WHEN ENTERING TRACKING MODE -----

    if (initial_freq > p->min_freq && initial_freq < p->max_freq) {
        p->asdf_offset = (int)roundf((1.0f / initial_freq) * (float)sp->sr);
        p->cur_period = p->asdf_offset;

        for (int offset = 0; offset <= p->num_offsets; offset++) {
            p->asdf[offset] = 0.0f;

            int l = p->asdf_offset + offset - p->num_offsets_2;

            for (int j = 0; j < l; j++) {
                float *samp;
                float *sampL;
                cb_read_at_index_behind_write(p->buff, -1 * j, &samp);
                cb_read_at_index_behind_write(p->buff, (-1 * j) - l, &sampL);
                p->asdf[offset] += powf(*samp - *sampL, 2);
            }
        }
    }

    // ----- UPDATE ASDF ARRAY -----



    for (int offset = 0; offset <= p->num_offsets; offset++) {
        int window_size = p->asdf_offset + offset - p->num_offsets_2;

        float *samp;
        float *sampL;
        float *samp2L;
        cb_read_at_index_behind_write(p->buff, 0, &samp);
        cb_read_at_index_behind_write(p->buff, -1 * window_size, &sampL);
        cb_read_at_index_behind_write(p->buff, -2 * window_size, &samp2L);

        if (*samp != *samp) {
            continue;
        }
        if (*sampL != *sampL) {
            continue;
        }
        if (*samp2L != *samp2L) {
            continue;
        }

        p->asdf[offset] += powf(*samp - *sampL, 2);
        p->asdf[offset] -= powf(*sampL - *samp2L, 2);
    }

    // ----- PERFORM PITCH TRACKING -----

    if (p->iter < 5) {
        p->iter++;
        *output_pitch = 1.0f / (p->cur_period / (float)sp->sr);
        return SP_OK;
    }
    // do this every 5th iteration
    p->iter = 1;

    float min_diff = -1;
    int new_l_min = 0;

    // find minimum average squared difference (ASDF)
    for (int i = 0; i <= p->num_offsets; i++) {
        float diff_normalized = p->asdf[i] / (float)(p->asdf_offset + i - p->num_offsets_2);
        if (diff_normalized < min_diff || min_diff == -1) {
            min_diff = diff_normalized;
            new_l_min = i;
        }
    }

    // ----- CHECK FOR TRACKING FAILURES -----

//    float eps = 0.6;
//    if (min_diff >= eps * p->asdf[new_l_min]) {
//        printf("no period detected\n");
//        return SP_NOT_OK;
//        // TRACKING FAILURE - NO PERIOD DETECTED
//    }

    if (new_l_min == 0 || new_l_min == p->num_offsets) {
        p->failure_count++;
//        printf("pitch changed too fast  - %i - %i\n", new_l_min, p->failure_count);
//        for (int offset = 0; offset <= p->num_offsets; offset++) {
//            printf("OFFSET %i\n", offset);
//            printf("%f\n", p->asdf[offset]);
//            float normalizedToWindow = p->asdf[offset] / (float)(p->asdf_offset + offset - (p->num_offsets_2));
//            printf("%f\n", normalizedToWindow);
//            printf("\n");
//        }

//        *output_pitch = 1.0f / (p->cur_period / (float)sp->sr);
        return SP_NOT_OK;
        // TRACKING FAILURE - PITCH CHANGED TOO FAST
    } else {
//        printf("new l min - %i\n", new_l_min);
    }

    float min_level = 0.0;
    if (p->asdf[new_l_min] < min_level) {
//        printf("level too low\n");
        return SP_NOT_OK;
        // TRACKING FAILURE - LEVEL TOO LOW
    }

    // ----- SUCCESS, UPDATE TRACKED PITCH -----

    float asdf_offset_before = p->asdf_offset;

    if (new_l_min < p->num_offsets_2) {
        // shift ASDF one index higher
        for (int i = 1; i <= p->num_offsets; i++) {
            p->asdf[i] = p->asdf[i - 1];
        }
        p->asdf_offset -= 1;

        // recalculate ASDF(0)
        p->asdf[0] = 0.0f;
        int l = p->asdf_offset - (p->num_offsets_2);
        for (int j = 0; j < l; j++) {
            float *samp;
            float *sampL;
            cb_read_at_index_behind_write(p->buff, -1 * j, &samp);
            cb_read_at_index_behind_write(p->buff, (-1 * j) - l, &sampL);
            p->asdf[0] += powf(*samp - *sampL, 2);
        }
    } else if (new_l_min > p->num_offsets_2) {
        // shift E and H one index lower
        for (int i = 0; i <= p->num_offsets - 1; i++) {
            p->asdf[i] = p->asdf[i + 1];
        }
        p->asdf_offset += 1;
//        printf("inc\n");

        // recalculate ASDF(N)
        p->asdf[p->num_offsets] = 0.0f;
        int l = p->asdf_offset + p->num_offsets - (p->num_offsets_2);
        for (int j = 0; j < l; j++) {
            float *samp;
            float *sampL;
            cb_read_at_index_behind_write(p->buff, -1 * j, &samp);
            cb_read_at_index_behind_write(p->buff, (-1 * j) - l, &sampL);
            p->asdf[p->num_offsets] += powf(*samp - *sampL, 2);
        }
    }

    // ----- INTERPOLATE BEST MIN -----

    int offLeft = new_l_min - 1;
    int offRight = new_l_min + 1;
    float valLeft = p->asdf[offLeft];
    float valRight = p->asdf[offRight];
    float interp_min = 0.0f;
    interpolate_min(offLeft, valLeft, new_l_min, min_diff, offRight, valRight, &interp_min);

    p->cur_period = asdf_offset_before + interp_min - ((float)p->num_offsets_2) - 1;
    *output_pitch = 1.0f / (p->cur_period / (float)sp->sr);
//    printf("%f\n", *output_pitch);

    return SP_OK;
}
