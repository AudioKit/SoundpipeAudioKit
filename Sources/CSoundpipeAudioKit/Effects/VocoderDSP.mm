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

public:
    VocoderDSP() {
        inputBufferLists.resize(2);  // Set up for two input streams
        parameters[VocoderParameterAttackTime] = &attackRamp;
        parameters[VocoderParameterReleaseTime] = &releaseRamp;
        parameters[VocoderParameterBandwidthRatio] = &bwRatioRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        
        // Create and initialize vocoders first
        sp_vocoder_create(&vocoderL);
        sp_vocoder_create(&vocoderR);

        // Initialize vocoders after setting parameters
        sp_vocoder_init(sp, vocoderL);
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
            
            *vocoderL->atk = *vocoderR->atk = attackRamp.getAndStep();
            *vocoderL->rel = *vocoderR->rel = releaseRamp.getAndStep();
            *vocoderL->bwratio = *vocoderR->bwratio = bwRatioRamp.getAndStep();
            
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
