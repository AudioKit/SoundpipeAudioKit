// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"

enum DryWetDualMixerParameter : AUParameterAddress {
    DryWetDualMixerParameterDry,
    DryWetDualMixerParameterWet,
};

class DryWetDualMixerDSP : public SoundpipeDSPBase {
private:
    ParameterRamper dryRamp;
    ParameterRamper wetRamp;

public:
    DryWetDualMixerDSP() {
        inputBufferLists.resize(2);
        parameters[DryWetDualMixerParameterDry] = &dryRamp;
        parameters[DryWetDualMixerParameterWet] = &wetRamp;
    }

    void process(FrameRange range) override {
        for (int i : range) {

            float dryAmount = dryRamp.getAndStep();
            float wetAmount = wetRamp.getAndStep();

            for (int channel = 0; channel < channelCount; ++channel) {
                float dry = inputSample(channel, i);
                float wet = input2Sample(channel, i);
                printf("%f %f %f %f \n", dryRamp.getUIValue(), dryAmount, wetAmount, wetRamp.getUIValue());
                outputSample(channel, i) =  dryAmount * dry + wetAmount * wet;
            }
        }
    }
};

AK_REGISTER_DSP(DryWetDualMixerDSP, "dwm2")
AK_REGISTER_PARAMETER(DryWetDualMixerParameterDry)
AK_REGISTER_PARAMETER(DryWetDualMixerParameterWet)
