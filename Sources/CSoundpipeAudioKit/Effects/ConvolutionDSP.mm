// Copyright AudioKit. All Rights Reserved.

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"
#include "CSoundpipeAudioKit.h"
#include <vector>

enum ConvolutionParameter : AUParameterAddress {
};

class ConvolutionDSP : public SoundpipeDSPBase {
private:
    sp_conv *conv0;
    sp_conv *conv1;
    sp_ftbl *ftbl[2];
    std::vector<float> wavetable[2];
    int partitionLength = 2048;
    int irChannels = 0;
    
public:
    ConvolutionDSP() {}

    void setIrChannels(int ch){
        irChannels = ch;
    }
    
    void setWavetable(const float *table, size_t length, int index) override {
        irChannels++;
        wavetable[index] = std::vector<float>(table, table + length);

        if (!isInitialized) return;
        
        sp_ftbl_destroy(&ftbl[index]);
        sp_ftbl_create(sp, &ftbl[index], wavetable[index].size());
        std::copy(wavetable[index].cbegin(), wavetable[index].cend(), ftbl[index]->tbl);
        reset();
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        
        for(int i = 0; i < irChannels; i++) {
            int size = wavetable[i].size();
            sp_ftbl_create(sp, &ftbl[i], wavetable[i].size());
            std::copy(wavetable[i].cbegin(), wavetable[i].cend(), ftbl[i]->tbl);
        }
        
        sp_conv_create(&conv0);
        sp_conv_init(sp, conv0, ftbl[0], (float)partitionLength);
        sp_conv_create(&conv1);
        sp_conv_init(sp, conv1, ftbl[irChannels-1], (float)partitionLength); 
    }

    void setPartitionLength(int partLength) {
        partitionLength = partLength;
        reset();
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_conv_destroy(&conv0);
        sp_conv_destroy(&conv1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_conv_init(sp, conv0, ftbl[0], (float)partitionLength);
        sp_conv_init(sp, conv1, ftbl[irChannels-1], (float)partitionLength);
    }

    void process(FrameRange range) override {
        for (int i : range) {
            
            sp_conv_compute(sp, conv0, &inputSample(0, i), &outputSample(0, i));
            sp_conv_compute(sp, conv1, &inputSample(1, i), &outputSample(1, i));

            // Hack
            outputSample(0, i) *= 0.05;
            outputSample(1, i) *= 0.05;
        }
    }
};

void akConvolutionSetPartitionLength(DSPRef dsp, int length) {
    ((ConvolutionDSP*)dsp)->setPartitionLength(length);
}

AK_REGISTER_DSP(ConvolutionDSP, "conv")
