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
        
        // Default chromatic scale from A1 (55Hz) to A6 (1760Hz)
        float defaultScale[73] = {
            55.00,   58.27,   61.74,   65.41,   69.30,   73.42,   77.78,   82.41,   87.31,   92.50,   98.00,   103.83,  // A1 to G#2
            110.00,  116.54,  123.47,  130.81,  138.59,  146.83,  155.56,  164.81,  174.61,  185.00,  196.00,  207.65,  // A2 to G#3
            220.00,  233.08,  246.94,  261.63,  277.18,  293.66,  311.13,  329.63,  349.23,  369.99,  392.00,  415.30,  // A3 to G#4
            440.00,  466.16,  493.88,  523.25,  554.37,  587.33,  622.25,  659.26,  698.46,  739.99,  783.99,  830.61,  // A4 to G#5
            880.00,  932.33,  987.77,  1046.50, 1108.73, 1174.66, 1244.51, 1318.51, 1396.91, 1479.98, 1567.98, 1661.22, // A5 to G#6
            1760.00                                                                                                       // A6
        };
        setWavetable(defaultScale, 73, 0);
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

