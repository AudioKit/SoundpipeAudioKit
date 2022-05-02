// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"

enum DryWetMixerParameter : AUParameterAddress {
    DryWetMixerParameterDry,
    DryWetMixerParameterWet,
};

class DryWetMixerDSP : public SoundpipeDSPBase {
private:
    ParameterRamper dryRamp;
    ParameterRamper wetRamp;

public:
    DryWetMixerDSP() {
        inputBufferLists.resize(2);
        parameters[DryWetMixerParameterDry] = &dryRamp;
        parameters[DryWetMixerParameterWet] = &wetRamp;
    }

    void process(FrameRange range) override {
        for (int i : range) {

            float dryAmount = dryRamp.getAndStep();
            float wetAmount = wetRamp.getAndStep();

            for (int channel = 0; channel < channelCount; ++channel) {
                float dry = inputSample(channel, i);
                float wet = input2Sample(channel, i);
                outputSample(channel, i) =  dryAmount * dry + wetAmount * wet;
            }
        }
    }
};

AK_REGISTER_DSP(DryWetMixerDSP, "dwmx")
AK_REGISTER_PARAMETER(DryWetMixerParameterDry)
AK_REGISTER_PARAMETER(DryWetMixerParameterWet)
