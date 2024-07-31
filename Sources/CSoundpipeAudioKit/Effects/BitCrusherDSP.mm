// Copyright AudioKit. All Rights Reserved.

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum BitCrusherParameter : AUParameterAddress {
    BitCrusherParameterBitDepth,
    BitCrusherParameterSampleRate,
    BitCrusherParameterDryWetMix
};

class BitCrusherDSP : public SoundpipeDSPBase {
private:
    sp_bitcrush *bitcrush0;
    sp_bitcrush *bitcrush1;
    ParameterRamper bitDepthRamp;
    ParameterRamper sampleRateRamp;
    ParameterRamper dryWetMixRamp;

public:
    BitCrusherDSP() {
        parameters[BitCrusherParameterBitDepth] = &bitDepthRamp;
        parameters[BitCrusherParameterSampleRate] = &sampleRateRamp;
        parameters[BitCrusherParameterDryWetMix] = &dryWetMixRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_bitcrush_create(&bitcrush0);
        sp_bitcrush_init(sp, bitcrush0);
        sp_bitcrush_create(&bitcrush1);
        sp_bitcrush_init(sp, bitcrush1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_bitcrush_destroy(&bitcrush0);
        sp_bitcrush_destroy(&bitcrush1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_bitcrush_init(sp, bitcrush0);
        sp_bitcrush_init(sp, bitcrush1);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            bitcrush0->bitdepth = bitcrush1->bitdepth = bitDepthRamp.getAndStep();
            bitcrush0->srate = bitcrush1->srate = sampleRateRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_bitcrush_compute(sp, bitcrush0, &leftIn, &leftOut);
            sp_bitcrush_compute(sp, bitcrush1, &rightIn, &rightOut);

            float dryWetMix = dryWetMixRamp.getAndStep();
            outputSample(0, i) = dryWetMix * leftOut + (1.0f - dryWetMix) * leftIn;
            outputSample(1, i) = dryWetMix * rightOut + (1.0f - dryWetMix) * rightIn;
        }
    }
};

AK_REGISTER_DSP(BitCrusherDSP, "btcr")
AK_REGISTER_PARAMETER(BitCrusherParameterBitDepth)
AK_REGISTER_PARAMETER(BitCrusherParameterSampleRate)
AK_REGISTER_PARAMETER(BitCrusherParameterDryWetMix)
