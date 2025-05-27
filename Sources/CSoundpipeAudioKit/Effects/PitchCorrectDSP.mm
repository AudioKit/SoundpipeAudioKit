// Copyright AudioKit. All Rights Reserved.

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"
#include "pitchcorrect.h"

enum PitchCorrectParameter : AUParameterAddress {
    PitchCorrectParameterSpeed,
    PitchCorrectParameterAmount
};

class PitchCorrectDSP : public SoundpipeDSPBase {
private:
    sp_rms *rms_l;
    sp_rms *rms_r;
    float *scale;
    int scaleCount;
    pitchcorrect *pitchcorrect_l;
    pitchcorrect *pitchcorrect_r;
    ParameterRamper speedRamp;
    ParameterRamper amountRamp;

public:
    PitchCorrectDSP() {
        parameters[PitchCorrectParameterSpeed] = &speedRamp;
        parameters[PitchCorrectParameterAmount] = &amountRamp;
    }
    
    void setWavetable(const float* table, size_t length, int index) override {
        scale = new float[length];
        memcpy(scale, table, length * sizeof(float));
        scaleCount = int(length);
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_rms_create(&rms_l);
        sp_rms_init(sp, rms_l);
        sp_rms_create(&rms_r);
        sp_rms_init(sp, rms_r);
        pitchcorrect_create(&pitchcorrect_l);
        pitchcorrect_init(sp, pitchcorrect_l);
        pitchcorrect_create(&pitchcorrect_r);
        pitchcorrect_init(sp, pitchcorrect_r);
        
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_rms_destroy(&rms_l);
        sp_rms_destroy(&rms_r);
        if (scale) {
            delete[] scale;
            scale = nullptr;
        }
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_rms_init(sp, rms_l);
        sp_rms_init(sp, rms_r);
    }
    
    void process(FrameRange range) override {
        for (int i : range) {
            float speed = speedRamp.getAndStep();
            float amount = amountRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);
            
            float rms_l_out = 0;
            float rms_r_out = 0;
            
            float leftOut = 0, rightOut = 0;
            
            pitchcorrect_set_scale_freqs(pitchcorrect_l, scale, scaleCount);
            pitchcorrect_set_scale_freqs(pitchcorrect_r, scale, scaleCount);


            pitchcorrect_set_speed(pitchcorrect_l, speed);
            pitchcorrect_set_amount(pitchcorrect_l, amount);

            pitchcorrect_set_speed(pitchcorrect_r, speed);
            pitchcorrect_set_amount(pitchcorrect_r, amount);
        
            sp_rms_compute(sp, rms_l, &leftIn, &rms_l_out);
            pitchcorrect_compute(sp, pitchcorrect_l, &leftIn, &leftOut, rms_l_out);
            
            sp_rms_compute(sp, rms_r, &rightIn, &rms_r_out);
            pitchcorrect_compute(sp, pitchcorrect_r, &rightIn, &rightOut, rms_r_out);
            
            outputSample(0, i) = leftOut;
            outputSample(1, i) = rightOut;
        }
    }
};

AK_REGISTER_DSP(PitchCorrectDSP, "pcrt")
AK_REGISTER_PARAMETER(PitchCorrectParameterSpeed)
AK_REGISTER_PARAMETER(PitchCorrectParameterAmount)
