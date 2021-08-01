// Copyright AudioKit. All Rights Reserved.

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"
#include <vector>

enum TremoloParameter : AUParameterAddress {
    TremoloParameterFrequency,
    TremoloParameterDepth,
};

struct WavetableInfo {
    sp_ftbl* table;

    ~WavetableInfo() {
        sp_ftbl_destroy(&table);
    }

    /// Is the audio thread done with the wavetable?
    std::atomic<bool> done{false};
};

class TremoloDSP : public SoundpipeDSPBase {
private:
    sp_dynamicosc *trem = nullptr;
    std::vector<float> initialWavetable;
    WavetableInfo *oldTable = nullptr;
    WavetableInfo *newTable = nullptr;
    double crossfade = 1.0;

    ParameterRamper frequencyRamp;
    ParameterRamper depthRamp;

    std::atomic<WavetableInfo*> nextWavetable;
    std::vector<std::unique_ptr<WavetableInfo>> oldTables;

public:
    TremoloDSP() {
        parameters[TremoloParameterFrequency] = &frequencyRamp;
        parameters[TremoloParameterDepth] = &depthRamp;
    }

    void collectTables() {

        // Once we find a finished table, all older tables can be released.
        int i;
        for(i=(int)oldTables.size()-1; i>=0; --i) {
            if(oldTables[i]->done)
                break;
        }

        oldTables.erase(oldTables.begin(), oldTables.begin()+i+1);
    }

    void setWavetable(const float* table, size_t length, int index) override {

        if(sp) {
            sendWavetable(table, length);
        } else {
            initialWavetable = std::vector<float>(table, table + length);
        }

    }

    void sendWavetable(const float* table, size_t length) {

        auto info = new WavetableInfo;

        sp_ftbl_create(sp, &info->table, length);
        std::copy(table, table+length, info->table->tbl);

        nextWavetable = info;

        // Store the table for collection later.
        oldTables.push_back(std::unique_ptr<WavetableInfo>(info));

        // Clean up any tables that are done.
        collectTables();

    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);

        sp_dynamicosc_create(&trem);
        sp_dynamicosc_init(sp, trem, 0);

        sendWavetable(initialWavetable.data(), initialWavetable.size());
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_dynamicosc_destroy(&trem);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_dynamicosc_init(sp, trem, 0);
    }

    void updateTables() {
        // Check for new waveforms.
        auto next = nextWavetable.load();
        if(next != newTable) {
            if(oldTable) { oldTable->done = true; }
            oldTable = newTable;
            if(oldTable) { crossfade = 0; }
            newTable = next;
        }
    }

    void process(FrameRange range) override {

        updateTables();

        for (int i : range) {
            trem->freq = frequencyRamp.getAndStep();
            trem->amp = depthRamp.getAndStep();

            crossfade += 0.005;
            if(crossfade > 1) { crossfade = 1; }

            float temp1 = 0;
            float temp2 = 0;

            if(oldTable) {
                sp_dynamicosc_compute(sp, trem, oldTable->table, nil, &temp1, false); // does not move phase
            }

            if(newTable) {
                sp_dynamicosc_compute(sp, trem, newTable->table, nil, &temp2, true); // does move phase
            }

            outputSample(0, i) = inputSample(0, i) * ((1.0 - temp1) * (1 - crossfade) + (1.0 - temp2) * crossfade);
            outputSample(1, i) = inputSample(1, i) * ((1.0 - temp1) * (1 - crossfade) + (1.0 - temp2) * crossfade);
        }
    }
};

AK_REGISTER_DSP(TremoloDSP, "trem")
AK_REGISTER_PARAMETER(TremoloParameterFrequency)
AK_REGISTER_PARAMETER(TremoloParameterDepth)
