#ifndef pitchshift_h
#define pitchshift_h

#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>
#include <stdio.h>
#include "Soundpipe.h"

#define MAX_FRAME_LENGTH 8192

typedef struct smbpitchshift {
    float gInFIFO[MAX_FRAME_LENGTH];
    float gOutFIFO[MAX_FRAME_LENGTH];
    float gFFTworksp[2*MAX_FRAME_LENGTH];
    float gLastPhase[MAX_FRAME_LENGTH/2+1];
    float gSumPhase[MAX_FRAME_LENGTH/2+1];
    float gOutputAccum[2*MAX_FRAME_LENGTH];
    float gAnaFreq[MAX_FRAME_LENGTH];
    float gAnaMagn[MAX_FRAME_LENGTH];
    float gSynFreq[MAX_FRAME_LENGTH];
    float gSynMagn[MAX_FRAME_LENGTH];
    long gRover;
    double freqPerBin, expct;
    float sampleRate;
    long fftFrameSize, osamp, inFifoLatency, stepSize, fftFrameSize2;
} smbpitchshift;

int smbpitchshift_create(smbpitchshift **p);
int smbpitchshift_init(smbpitchshift *p, long fftFrameSize, long osamp, float sampleRate);
void smbpitchshift_compute(smbpitchshift *p, float shift, long numSampsToProcess, float *indata, float *outdata);
void smbFft(float *fftBuffer, long fftFrameSize, long sign);

#endif /* pitchshift_h */
