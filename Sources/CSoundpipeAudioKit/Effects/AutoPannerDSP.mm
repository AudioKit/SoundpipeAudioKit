// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

#import <vector>

enum AutoPannerParameter : AUParameterAddress {
    AutoPannerParameterFrequency,
    AutoPannerParameterDepth,
};

class AutoPannerDSP : public SoundpipeDSPBase {
private:
    sp_osc *trem;
    sp_ftbl *tbl;
    sp_panst *panst;
    std::vector<float> wavetable;
    ParameterRamper frequencyRamp;
    ParameterRamper depthRamp;

public:
    AutoPannerDSP() {
        parameters[AutoPannerParameterFrequency] = &frequencyRamp;
        parameters[AutoPannerParameterDepth] = &depthRamp;
    }

    void setWavetable(const float* table, size_t length, int index) override {
        wavetable = std::vector<float>(table, table + length);
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_ftbl_create(sp, &tbl, wavetable.size());
        std::copy(wavetable.cbegin(), wavetable.cend(), tbl->tbl);
        sp_osc_create(&trem);
        sp_osc_init(sp, trem, tbl, 0);
        sp_panst_create(&panst);
        sp_panst_init(sp, panst);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_osc_destroy(&trem);
        sp_panst_destroy(&panst);
        sp_ftbl_destroy(&tbl);
    }

    void process(FrameRange range) override {
        for(auto i : range) {

            trem->freq = frequencyRamp.getAndStep();
            trem->amp = 1;

            float temp = 0;
            sp_osc_compute(sp, trem, NULL, &temp);
            panst->pan = (2.0 * temp - 1.0) * depthRamp.getAndStep();
            sp_panst_compute(sp,
                             panst,
                             &inputSample(0, i), &inputSample(1, i),
                             &outputSample(0, i), &outputSample(1, i));

        }
    }

};

AK_REGISTER_DSP(AutoPannerDSP, "apan")
AK_REGISTER_PARAMETER(AutoPannerParameterFrequency)
AK_REGISTER_PARAMETER(AutoPannerParameterDepth)
