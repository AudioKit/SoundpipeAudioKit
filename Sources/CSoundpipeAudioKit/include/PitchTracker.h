// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <Foundation/Foundation.h>
#include "Interop.h"

CF_EXTERN_C_BEGIN

typedef struct PitchTracker *PitchTrackerRef;

PitchTrackerRef akPitchTrackerCreate(unsigned int sampleRate, int hopSize, int peakCount);
void akPitchTrackerDestroy(PitchTrackerRef);

void akPitchTrackerAnalyze(PitchTrackerRef tracker, float* frames, unsigned int count);
void akPitchTrackerGetResults(PitchTrackerRef tracker, float* trackedAmplitude, float* trackedFrequency);

CF_EXTERN_C_END
