#ifndef pitchcorrect_h
#define pitchcorrect_h

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include "Soundpipe.h"
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
    float *pitchcorrect_scale_freqs;
    int pitchcorrect_scale_freqs_count;
    float *tmp_scale_freqs;
    int tmp_scale_freqs_count;
} pitchcorrect;

int pitchcorrect_create(pitchcorrect **p);
int pitchcorrect_init(sp_data *sp, pitchcorrect *p);
int pitchcorrect_compute(sp_data *sp, pitchcorrect *p, float *in, float *out, float rms);
int pitchcorrect_set_scale_freqs(pitchcorrect *p, float *frequencies, int count);
int pitchcorrect_set_amount(pitchcorrect *p, float amount);
int pitchcorrect_set_speed(pitchcorrect *p, float speed);

#ifdef __cplusplus
}
#endif


#endif /* pitchcorrect_h */

