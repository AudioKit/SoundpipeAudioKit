// Copyright AudioKit. All Rights Reserved.

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"
#include "CSoundpipeAudioKit.h"

enum VariableDelayParameter : AUParameterAddress {
    VariableDelayParameterTime,
    VariableDelayParameterFeedback,
    VariableDelayParameterDryWetMix
};

class VariableDelayDSP : public SoundpipeDSPBase {
private:
    sp_vdelay *vdelay0;
    sp_vdelay *vdelay1;
    float maximumTime = 10.0;
    ParameterRamper timeRamp;
    ParameterRamper feedbackRamp;
    ParameterRamper dryWetMixRamp;

public:
    VariableDelayDSP() : SoundpipeDSPBase(1, false) {
        parameters[VariableDelayParameterTime] = &timeRamp;
        parameters[VariableDelayParameterFeedback] = &feedbackRamp;
        parameters[VariableDelayParameterDryWetMix] = &dryWetMixRamp;
    }

    void setMaximumTime(float maxTime) {
        maximumTime = maxTime;
        reset();
    }


    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_vdelay_create(&vdelay0);
        sp_vdelay_init(sp, vdelay0, maximumTime);
        sp_vdelay_create(&vdelay1);
        sp_vdelay_init(sp, vdelay1, maximumTime);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_vdelay_destroy(&vdelay0);
        sp_vdelay_destroy(&vdelay1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_vdelay_init(sp, vdelay0, maximumTime);
        sp_vdelay_init(sp, vdelay1, maximumTime);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            float time = timeRamp.getAndStep();
            if (time > maximumTime) time = maximumTime;
            vdelay0->del = vdelay1->del = time;

            vdelay0->feedback = vdelay1->feedback = feedbackRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_vdelay_compute(sp, vdelay0, &leftIn, &leftOut);
            sp_vdelay_compute(sp, vdelay1, &rightIn, &rightOut);

            float dryWetMix = dryWetMixRamp.getAndStep();
            outputSample(0, i) = dryWetMix * leftOut + (1.0f - dryWetMix) * leftIn;
            outputSample(1, i) = dryWetMix * rightOut + (1.0f - dryWetMix) * rightIn;
        }
    }
};

void akVariableDelaySetMaximumTime(DSPRef dspRef, float maximumTime) {
    auto dsp = dynamic_cast<VariableDelayDSP *>(dspRef);
    assert(dsp);
    dsp->setMaximumTime(maximumTime);
}

AK_REGISTER_DSP(VariableDelayDSP, "vdla")
AK_REGISTER_PARAMETER(VariableDelayParameterTime)
AK_REGISTER_PARAMETER(VariableDelayParameterFeedback)
AK_REGISTER_PARAMETER(VariableDelayParameterDryWetMix)
