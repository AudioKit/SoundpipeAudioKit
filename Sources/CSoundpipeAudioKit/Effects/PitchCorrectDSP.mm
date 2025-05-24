// Copyright AudioKit. All Rights Reserved.

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"
#include "autotune.h"

enum PitchCorrectParameter : AUParameterAddress {
    PitchCorrectParameterSpeed,
    PitchCorrectParameterAmount
};

class PitchCorrectDSP : public SoundpipeDSPBase {
private:
    sp_rms *rms_l;
    sp_rms *rms_r;
    autotune *autotune_l;
    autotune *autotune_r;
    ParameterRamper speedRamp;
    ParameterRamper amountRamp;

public:
    PitchCorrectDSP() {
        parameters[PitchCorrectParameterSpeed] = &speedRamp;
        parameters[PitchCorrectParameterAmount] = &amountRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_rms_create(&rms_l);
        sp_rms_init(sp, rms_l);
        sp_rms_create(&rms_r);
        sp_rms_init(sp, rms_r);
        autotune_create(&autotune_l);
        autotune_init(sp, autotune_l);
        autotune_create(&autotune_r);
        autotune_init(sp, autotune_r);
        
        // Create chromatic scale from A220 to A440
        float scale[13] = {
            220.0,  // A
            233.08, // A#/Bb
            246.94, // B
            261.63, // C
            277.18, // C#/Db
            293.66, // D
            311.13, // D#/Eb
            329.63, // E
            349.23, // F
            369.99, // F#/Gb
            392.00, // G
            415.30, // G#/Ab
            440.00  // A
        };
        
        autotune_set_scale_freqs(autotune_l, scale, 13);
        autotune_set_scale_freqs(autotune_r, scale, 13);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_rms_destroy(&rms_l);
        sp_rms_destroy(&rms_r);
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
            
            autotune_set_speed(autotune_l, speed);
            autotune_set_amount(autotune_l, amount);

            autotune_set_speed(autotune_r, speed);
            autotune_set_amount(autotune_r, amount);
        
            sp_rms_compute(sp, rms_l, &leftIn, &rms_l_out);
            autotune_compute(sp, autotune_l, &leftIn, &leftOut, rms_l_out);
            
            sp_rms_compute(sp, rms_r, &rightIn, &rms_r_out);
            autotune_compute(sp, autotune_r, &rightIn, &rightOut, rms_r_out);
            
            outputSample(0, i) = leftOut;
            outputSample(1, i) = rightOut;
        }
    }
};

AK_REGISTER_DSP(PitchCorrectDSP, "pcrt")
AK_REGISTER_PARAMETER(PitchCorrectParameterSpeed)
AK_REGISTER_PARAMETER(PitchCorrectParameterAmount)
