// Copyright AudioKit. All Rights Reserved.

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum VibratoParameter : AUParameterAddress {
    VibratoParameterSpeed,
    VibratoParameterDepth
};

class VibratoDSP : public SoundpipeDSPBase {
private:
    sp_osc *vibrato;
    sp_pshift *pshift;
    sp_ftbl *sine;
    ParameterRamper speedRamp;
    ParameterRamper depthRamp;

public:
    VibratoDSP() {
        parameters[VibratoParameterSpeed] = &speedRamp;
        parameters[VibratoParameterDepth] = &depthRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        
        sp_ftbl_create(sp, &sine, 4096);
        sp_gen_sine(sp, sine);
        
        sp_osc_create(&vibrato);
        sp_osc_init(sp, vibrato, sine, 0);
        
        sp_pshift_create(&pshift);
        sp_pshift_init(sp, pshift);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_osc_destroy(&vibrato);
        sp_pshift_destroy(&pshift);
        sp_ftbl_destroy(&sine);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_osc_init(sp, vibrato, sine, 0);
    }

    void process(FrameRange range) override {
        float vibrato_out = 0;

        for (int i : range) {
            float speed = speedRamp.getAndStep();
            float depth = depthRamp.getAndStep();
            
            vibrato->freq = speed;
            sp_osc_compute(sp, vibrato, NULL, &vibrato_out);
            *pshift->shift = vibrato_out * depth;
            
            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float leftOut, rightOut;
            sp_pshift_compute(sp, pshift, &leftIn, &leftOut);
            sp_pshift_compute(sp, pshift, &rightIn, &rightOut);
            
            outputSample(0, i) = leftOut;
            outputSample(1, i) = rightOut;
        }
    }
};

AK_REGISTER_DSP(VibratoDSP, "vbrt")
AK_REGISTER_PARAMETER(VibratoParameterSpeed)
AK_REGISTER_PARAMETER(VibratoParameterDepth)
