// Copyright AudioKit. All Rights Reserved.

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum DiodeLadderFilterParameter : AUParameterAddress {
    DiodeLadderFilterParameterCutoffFrequency,
    DiodeLadderFilterParameterResonance,
};

class DiodeLadderFilterDSP : public SoundpipeDSPBase {
private:
    sp_diode *diode0;
    sp_diode *diode1;
    ParameterRamper cutoffFrequencyRamp;
    ParameterRamper resonanceRamp;

public:
    DiodeLadderFilterDSP() {
        parameters[DiodeLadderFilterParameterCutoffFrequency] = &cutoffFrequencyRamp;
        parameters[DiodeLadderFilterParameterResonance] = &resonanceRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_diode_create(&diode0);
        sp_diode_init(sp, diode0);
        sp_diode_create(&diode1);
        sp_diode_init(sp, diode1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_diode_destroy(&diode0);
        sp_diode_destroy(&diode1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_diode_init(sp, diode0);
        sp_diode_init(sp, diode1);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            diode0->freq = diode1->freq = cutoffFrequencyRamp.getAndStep();
            diode0->res = diode1->res = resonanceRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_diode_compute(sp, diode0, &leftIn, &leftOut);
            sp_diode_compute(sp, diode1, &rightIn, &rightOut);
        }
    }
};

AK_REGISTER_DSP(DiodeLadderFilterDSP, "diod")
AK_REGISTER_PARAMETER(DiodeLadderFilterParameterCutoffFrequency)
AK_REGISTER_PARAMETER(DiodeLadderFilterParameterResonance)
