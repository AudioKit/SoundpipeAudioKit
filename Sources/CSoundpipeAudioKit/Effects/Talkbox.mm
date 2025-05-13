// Copyright AudioKit. All Rights Reserved.

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum TalkboxParameter : AUParameterAddress {
    TalkboxParameterQuality,
};

class TalkboxDSP : public SoundpipeDSPBase {
private:
    sp_talkbox *talkboxL;
    sp_talkbox *talkboxR;
    ParameterRamper qualityRamp{1.0};

public:
    TalkboxDSP() {
        inputBufferLists.resize(2);  // Set up for two input streams
        parameters[TalkboxParameterQuality] = &qualityRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_talkbox_create(&talkboxL);
        sp_talkbox_init(sp, talkboxL);
        sp_talkbox_create(&talkboxR);
        sp_talkbox_init(sp, talkboxR);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_talkbox_destroy(&talkboxL);
        sp_talkbox_destroy(&talkboxR);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_talkbox_init(sp, talkboxL);
        sp_talkbox_init(sp, talkboxR);
    }

    void process(FrameRange range) override {
        for (int i : range) {
            float sourceInL = inputSample(0, i);      // modulator input left
            float sourceInR = inputSample(1, i);      // modulator input right
            float excitationInL = input2Sample(0, i); // carrier input left
            float excitationInR = input2Sample(1, i); // carrier input right
            float outSampleL;
            float outSampleR;

            float quality = qualityRamp.getAndStep();
            talkboxL->quality = quality;
            talkboxR->quality = quality;

            sp_talkbox_compute(sp, talkboxL, &sourceInL, &excitationInL, &outSampleL);
            sp_talkbox_compute(sp, talkboxR, &sourceInR, &excitationInR, &outSampleR);

            outputSample(0, i) = outSampleL;
            outputSample(1, i) = outSampleR;
        }
    }
};

AK_REGISTER_DSP(TalkboxDSP, "tbox")
AK_REGISTER_PARAMETER(TalkboxParameterQuality)
