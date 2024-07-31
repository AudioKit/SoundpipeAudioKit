// Copyright AudioKit. All Rights Reserved.

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum PitchShifterParameter : AUParameterAddress {
    PitchShifterParameterShift,
    PitchShifterParameterWindowSize,
    PitchShifterParameterCrossfade,
    PitchShifterParameterDryWetMix
};

class PitchShifterDSP : public SoundpipeDSPBase {
private:
    sp_pshift *pshift0;
    sp_pshift *pshift1;
    ParameterRamper shiftRamp;
    ParameterRamper windowSizeRamp;
    ParameterRamper crossfadeRamp;
    ParameterRamper dryWetMixRamp;

public:
    PitchShifterDSP() {
        parameters[PitchShifterParameterShift] = &shiftRamp;
        parameters[PitchShifterParameterWindowSize] = &windowSizeRamp;
        parameters[PitchShifterParameterCrossfade] = &crossfadeRamp;
        parameters[PitchShifterParameterDryWetMix] = &dryWetMixRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_pshift_create(&pshift0);
        sp_pshift_init(sp, pshift0);
        sp_pshift_create(&pshift1);
        sp_pshift_init(sp, pshift1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_pshift_destroy(&pshift0);
        sp_pshift_destroy(&pshift1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        void *old1 = pshift0->faust;
        void *old2 = pshift1->faust;
        sp_pshift_init(sp, pshift0);
        sp_pshift_init(sp, pshift1);
        free(old1);
        free(old2);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            *pshift0->shift = *pshift1->shift = shiftRamp.getAndStep();
            *pshift0->window = *pshift1->window = windowSizeRamp.getAndStep();
            *pshift0->xfade = *pshift1->xfade = crossfadeRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_pshift_compute(sp, pshift0, &leftIn, &leftOut);
            sp_pshift_compute(sp, pshift1, &rightIn, &rightOut);
            
            float dryWetMix = dryWetMixRamp.getAndStep();
            outputSample(0, i) = dryWetMix * leftOut + (1.0f - dryWetMix) * leftIn;
            outputSample(1, i) = dryWetMix * rightOut + (1.0f - dryWetMix) * rightIn;
        }
    }
};

AK_REGISTER_DSP(PitchShifterDSP, "pshf")
AK_REGISTER_PARAMETER(PitchShifterParameterShift)
AK_REGISTER_PARAMETER(PitchShifterParameterWindowSize)
AK_REGISTER_PARAMETER(PitchShifterParameterCrossfade)
AK_REGISTER_PARAMETER(PitchShifterParameterDryWetMix)
