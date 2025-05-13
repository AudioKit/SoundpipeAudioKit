// Copyright AudioKit. All Rights Reserved.

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum VocoderParameter : AUParameterAddress {
    VocoderParameterAttackTime,
    VocoderParameterReleaseTime,
    VocoderParameterBandwidthRatio
};

class VocoderDSP : public SoundpipeDSPBase {
private:
    sp_vocoder *vocoderL;
    sp_vocoder *vocoderR;
    ParameterRamper attackRamp{0.1};
    ParameterRamper releaseRamp{0.1};
    ParameterRamper bwRatioRamp{0.5};
    
    float attackTimeL = 0.1;
    float releaseTimeL = 0.1;
    float bwRatioL = 0.5;
    float attackTimeR = 0.1;
    float releaseTimeR = 0.1;
    float bwRatioR = 0.5;

public:
    VocoderDSP() {
        inputBufferLists.resize(2);  // Set up for two input streams
        parameters[VocoderParameterAttackTime] = &attackRamp;
        parameters[VocoderParameterReleaseTime] = &releaseRamp;
        parameters[VocoderParameterBandwidthRatio] = &bwRatioRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_vocoder_create(&vocoderL);
        sp_vocoder_init(sp, vocoderL);
        sp_vocoder_create(&vocoderR);
        sp_vocoder_init(sp, vocoderR);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_vocoder_destroy(&vocoderL);
        sp_vocoder_destroy(&vocoderR);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_vocoder_init(sp, vocoderL);
        sp_vocoder_init(sp, vocoderR);
    }

    void process(FrameRange range) override {
        for (int i : range) {
            float sourceInL = inputSample(0, i);      // carrier input left
            float sourceInR = inputSample(1, i);      // carrier input right
            float excitationInL = input2Sample(0, i); // modulator input left
            float excitationInR = input2Sample(1, i); // modulator input right
            float outSampleL;
            float outSampleR;

            attackTimeL = attackRamp.getAndStep();
            releaseTimeL = releaseRamp.getAndStep();
            bwRatioL = bwRatioRamp.getAndStep();
            
            attackTimeR = attackTimeL;
            releaseTimeR = releaseTimeL;
            bwRatioR = bwRatioL;

            vocoderL->atk = &attackTimeL;
            vocoderL->rel = &releaseTimeL;
            vocoderL->bwratio = &bwRatioL;
            vocoderR->atk = &attackTimeR;
            vocoderR->rel = &releaseTimeR;
            vocoderR->bwratio = &bwRatioR;

            sp_vocoder_compute(sp, vocoderL, &sourceInL, &excitationInL, &outSampleL);
            sp_vocoder_compute(sp, vocoderR, &sourceInR, &excitationInR, &outSampleR);

            outputSample(0, i) = outSampleL;
            outputSample(1, i) = outSampleR;
        }
    }
};

AK_REGISTER_DSP(VocoderDSP, "vcdr")
AK_REGISTER_PARAMETER(VocoderParameterAttackTime)
AK_REGISTER_PARAMETER(VocoderParameterReleaseTime)
AK_REGISTER_PARAMETER(VocoderParameterBandwidthRatio)
