#ifndef autotune_h
#define autotune_h

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include "soundpipe.h"
#include "Yin.h"
#include "circular_buffer.h"
#include "pitchshift.h"
#include "pitchshift2.h"
#include "pitchcalculate.h"

typedef struct {
    pitchcalculate *pcalc;
    pitchshift2 *pshift2;
    Yin *yin;
    circular_buffer *buff;
    sp_butlp *lpf;
    sp_port *scale_freq_port;
    int16_t *intBuffer;
    int yin_downsample_acc;
    bool correction_mode_active;
    float detected_freq;
    float cur_correction_amt_cents;
    float base_freq;
    float target_freq;
    float pshift_freq_ratio;
    float cur_freq_ratio;
    int scale_freq_index_acc;
    int unknown_freq_acc;
    float nearest_scale_freq_index;
    float nearest_scale_freq;
    float amount;
    float speed;
    bool should_smooth_scale_idx;
    bool should_smooth_target_freq;

    bool should_update_scale_freqs;
    float *autotune_scale_freqs;
    int autotune_scale_freqs_count;
    float *tmp_scale_freqs;
    int tmp_scale_freqs_count;
} autotune;

int autotune_create(autotune **p);
int autotune_init(sp_data *sp, autotune *p);
int autotune_compute(sp_data *sp, autotune *p, float *in, float *out, float rms);
int autotune_set_scale_freqs(autotune *p, float *frequencies, int count);
int autotune_set_amount(autotune *p, float amount);
int autotune_set_speed(autotune *p, float speed);

#endif /* autotune_h */
