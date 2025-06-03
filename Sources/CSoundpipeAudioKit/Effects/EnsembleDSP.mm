// Copyright AudioKit. All Rights Reserved.

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum EnsembleParameter : AUParameterAddress {
    EnsembleParameterShift1,
    EnsembleParameterShift2,
    EnsembleParameterShift3,
    EnsembleParameterShift4,
    EnsembleParameterShift5,
    EnsembleParameterShift6,
    EnsembleParameterShift7,
    EnsembleParameterShift8,
    EnsembleParameterShift9,
    EnsembleParameterPan1,
    EnsembleParameterPan2,
    EnsembleParameterPan3,
    EnsembleParameterPan4,
    EnsembleParameterPan5,
    EnsembleParameterPan6,
    EnsembleParameterPan7,
    EnsembleParameterPan8,
    EnsembleParameterPan9,
    EnsembleParameterDryWetMix
};

class EnsembleDSP : public SoundpipeDSPBase {
private:
    // 9 pitch shifters for left channel
    sp_pshift *pshift_left[9];
    // 9 pitch shifters for right channel
    sp_pshift *pshift_right[9];
    // 9 panners
    sp_panst *panst[9];
    
    ParameterRamper shiftRamps[9];
    ParameterRamper panRamps[9];
    ParameterRamper dryWetMixRamp;

public:
    EnsembleDSP() {
        parameters[EnsembleParameterShift1] = &shiftRamps[0];
        parameters[EnsembleParameterShift2] = &shiftRamps[1];
        parameters[EnsembleParameterShift3] = &shiftRamps[2];
        parameters[EnsembleParameterShift4] = &shiftRamps[3];
        parameters[EnsembleParameterShift5] = &shiftRamps[4];
        parameters[EnsembleParameterShift6] = &shiftRamps[5];
        parameters[EnsembleParameterShift7] = &shiftRamps[6];
        parameters[EnsembleParameterShift8] = &shiftRamps[7];
        parameters[EnsembleParameterShift9] = &shiftRamps[8];
        parameters[EnsembleParameterPan1] = &panRamps[0];
        parameters[EnsembleParameterPan2] = &panRamps[1];
        parameters[EnsembleParameterPan3] = &panRamps[2];
        parameters[EnsembleParameterPan4] = &panRamps[3];
        parameters[EnsembleParameterPan5] = &panRamps[4];
        parameters[EnsembleParameterPan6] = &panRamps[5];
        parameters[EnsembleParameterPan7] = &panRamps[6];
        parameters[EnsembleParameterPan8] = &panRamps[7];
        parameters[EnsembleParameterPan9] = &panRamps[8];
        parameters[EnsembleParameterDryWetMix] = &dryWetMixRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        
        // Initialize pitch shifters and panners
        for (int i = 0; i < 9; i++) {
            // Left channel pitch shifters
            sp_pshift_create(&pshift_left[i]);
            sp_pshift_init(sp, pshift_left[i]);
            
            // Right channel pitch shifters
            sp_pshift_create(&pshift_right[i]);
            sp_pshift_init(sp, pshift_right[i]);
            
            // Panners
            sp_panst_create(&panst[i]);
            sp_panst_init(sp, panst[i]);
        }
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        
        for (int i = 0; i < 9; i++) {
            sp_pshift_destroy(&pshift_left[i]);
            sp_pshift_destroy(&pshift_right[i]);
            sp_panst_destroy(&panst[i]);
        }
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        
        // Reset all pitch shifters and panners
        for (int i = 0; i < 9; i++) {
            void *old_left = pshift_left[i]->faust;
            void *old_right = pshift_right[i]->faust;
            
            sp_pshift_init(sp, pshift_left[i]);
            sp_pshift_init(sp, pshift_right[i]);
            sp_panst_init(sp, panst[i]);
            
            free(old_left);
            free(old_right);
        }
    }

    void process(FrameRange range) override {
        for (int i : range) {
            float dryWetMix = dryWetMixRamp.getAndStep();
            
            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float leftSum = 0.0f;
            float rightSum = 0.0f;
            
            // Process through all 9 pitch shifters
            for (int voice = 0; voice < 9; voice++) {
                float shift = shiftRamps[voice].getAndStep();
                float pan = panRamps[voice].getAndStep();
                
                // Set pitch shift parameters
                *pshift_left[voice]->shift = *pshift_right[voice]->shift = shift;
                *pshift_left[voice]->window = *pshift_right[voice]->window = 1024;
                *pshift_left[voice]->xfade = *pshift_right[voice]->xfade = 512;
                
                // Process audio through pitch shifters
                float leftOut, rightOut;
                sp_pshift_compute(sp, pshift_left[voice], &leftIn, &leftOut);
                sp_pshift_compute(sp, pshift_right[voice], &rightIn, &rightOut);
                
                // Set pan parameter and apply panning
                panst[voice]->pan = pan;
                float pannedLeft, pannedRight;
                sp_panst_compute(sp, panst[voice], &leftOut, &rightOut, &pannedLeft, &pannedRight);
                
                // Add to sum with appropriate gain (divide by 9 to prevent clipping)
                leftSum += pannedLeft / 9.0f;
                rightSum += pannedRight / 9.0f;
            }
            
            // Apply dry/wet mix
            outputSample(0, i) = dryWetMix * leftSum + (1.0f - dryWetMix) * leftIn;
            outputSample(1, i) = dryWetMix * rightSum + (1.0f - dryWetMix) * rightIn;
        }
    }
};

AK_REGISTER_DSP(EnsembleDSP, "ensm")
AK_REGISTER_PARAMETER(EnsembleParameterShift1)
AK_REGISTER_PARAMETER(EnsembleParameterShift2)
AK_REGISTER_PARAMETER(EnsembleParameterShift3)
AK_REGISTER_PARAMETER(EnsembleParameterShift4)
AK_REGISTER_PARAMETER(EnsembleParameterShift5)
AK_REGISTER_PARAMETER(EnsembleParameterShift6)
AK_REGISTER_PARAMETER(EnsembleParameterShift7)
AK_REGISTER_PARAMETER(EnsembleParameterShift8)
AK_REGISTER_PARAMETER(EnsembleParameterShift9)
AK_REGISTER_PARAMETER(EnsembleParameterPan1)
AK_REGISTER_PARAMETER(EnsembleParameterPan2)
AK_REGISTER_PARAMETER(EnsembleParameterPan3)
AK_REGISTER_PARAMETER(EnsembleParameterPan4)
AK_REGISTER_PARAMETER(EnsembleParameterPan5)
AK_REGISTER_PARAMETER(EnsembleParameterPan6)
AK_REGISTER_PARAMETER(EnsembleParameterPan7)
AK_REGISTER_PARAMETER(EnsembleParameterPan8)
AK_REGISTER_PARAMETER(EnsembleParameterPan9)
AK_REGISTER_PARAMETER(EnsembleParameterDryWetMix)
