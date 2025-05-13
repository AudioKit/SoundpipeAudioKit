// Copyright AudioKit. All Rights Reserved.

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum TalkboxParameter : AUParameterAddress {
    TalkboxParameterQuality,
};

class TalkboxDSP : public SoundpipeDSPBase {
private:
    sp_talkbox *talkbox;
    ParameterRamper qualityRamp{1.0};

public:
    TalkboxDSP() {
        inputBufferLists.resize(2);  // Set up for two input streams
        parameters[TalkboxParameterQuality] = &qualityRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_talkbox_create(&talkbox);
        sp_talkbox_init(sp, talkbox);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_talkbox_destroy(&talkbox);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_talkbox_init(sp, talkbox);
    }

    void process(FrameRange range) override {
        for (int i : range) {
            float sourceIn = inputSample(0, i);      // source input (first input stream)
            float excitationIn = input2Sample(0, i); // excitation input (second input stream)
            float outSample;

            talkbox->quality = qualityRamp.getAndStep();
 
            sp_talkbox_compute(sp, talkbox, &sourceIn, &excitationIn, &outSample);

            outputSample(0, i) = outSample;
        }
    }
};

AK_REGISTER_DSP(TalkboxDSP, "tbox")
AK_REGISTER_PARAMETER(TalkboxParameterQuality)
