// Copyright AudioKit. All Rights Reserved.

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum ChowningReverbParameter : AUParameterAddress {
    ChowningReverbParameterBalance,
};

class ChowningReverbDSP : public SoundpipeDSPBase {
private:
    sp_jcrev *jcrev0;
    sp_jcrev *jcrev1;
    ParameterRamper balanceRamp{1.0};

public:
    ChowningReverbDSP() {
        parameters[ChowningReverbParameterBalance] = &balanceRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_jcrev_create(&jcrev0);
        sp_jcrev_init(sp, jcrev0);
        sp_jcrev_create(&jcrev1);
        sp_jcrev_init(sp, jcrev1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_jcrev_destroy(&jcrev0);
        sp_jcrev_destroy(&jcrev1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_jcrev_init(sp, jcrev0);
        sp_jcrev_init(sp, jcrev1);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float leftWet;
            float rightWet;

            sp_jcrev_compute(sp, jcrev0, &leftIn, &leftWet);
            sp_jcrev_compute(sp, jcrev1, &rightIn, &rightWet);

            float bal = balanceRamp.getAndStep();

            outputSample(0, i) = bal * leftWet + (1-bal) * leftIn;
            outputSample(1, i) = bal * rightWet + (1-bal) * rightIn;
        }
    }
};

AK_REGISTER_DSP(ChowningReverbDSP, "jcrv")
AK_REGISTER_PARAMETER(ChowningReverbParameterBalance)
