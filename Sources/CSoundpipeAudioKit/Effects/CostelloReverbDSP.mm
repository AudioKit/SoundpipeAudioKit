// Copyright AudioKit. All Rights Reserved.

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum CostelloReverbParameter : AUParameterAddress {
    CostelloReverbParameterFeedback,
    CostelloReverbParameterCutoffFrequency,
    CostelloReverbParameterBalance,
};

class CostelloReverbDSP : public SoundpipeDSPBase {
private:
    sp_revsc *revsc;
    ParameterRamper feedbackRamp;
    ParameterRamper cutoffFrequencyRamp;
    ParameterRamper balanceRamp{1.0};

public:
    CostelloReverbDSP() {
        parameters[CostelloReverbParameterFeedback] = &feedbackRamp;
        parameters[CostelloReverbParameterCutoffFrequency] = &cutoffFrequencyRamp;
        parameters[CostelloReverbParameterBalance] = &balanceRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_revsc_create(&revsc);
        sp_revsc_init(sp, revsc);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_revsc_destroy(&revsc);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_revsc_init(sp, revsc);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            revsc->feedback = feedbackRamp.getAndStep();
            revsc->lpfreq = cutoffFrequencyRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float leftWet;
            float rightWet;
            
            sp_revsc_compute(sp, revsc, &leftIn, &rightIn, &leftWet, &rightWet);

            float bal = balanceRamp.getAndStep();

            outputSample(0, i) = bal * leftWet + (1-bal) * leftIn;
            outputSample(1, i) = bal * rightWet + (1-bal) * rightIn;
        }
    }
};

AK_REGISTER_DSP(CostelloReverbDSP, "rvsc")
AK_REGISTER_PARAMETER(CostelloReverbParameterFeedback)
AK_REGISTER_PARAMETER(CostelloReverbParameterCutoffFrequency)
AK_REGISTER_PARAMETER(CostelloReverbParameterBalance)
