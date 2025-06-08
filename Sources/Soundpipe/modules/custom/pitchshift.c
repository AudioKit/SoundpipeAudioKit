#include "pitchshift.h"

#define MAX_FRAME_LENGTH 8192

void smbFft(float *fftBuffer, long fftFrameSize, long sign);
double smbAtan2(double x, double y);

int smbpitchshift_create(smbpitchshift **p) {
    *p = malloc(sizeof(smbpitchshift));
    return SP_OK;
}

int smbpitchshift_init(smbpitchshift *p, long fftFrameSize, long osamp, float sampleRate) {
    /* set up some handy variables */
    p->fftFrameSize = fftFrameSize;
    p->osamp = osamp;
    p->fftFrameSize2 = fftFrameSize/2;
    p->stepSize = fftFrameSize/osamp;
    p->freqPerBin = sampleRate/(double)fftFrameSize;
    p->expct = 2. * M_PI * (double)p->stepSize / (double)fftFrameSize;
    p->inFifoLatency = fftFrameSize - p->stepSize;
    p->gRover = p->inFifoLatency;
    p->sampleRate = sampleRate;

    /* initialize our static arrays */
    memset(p->gInFIFO, 0, MAX_FRAME_LENGTH*sizeof(float));
    memset(p->gOutFIFO, 0, MAX_FRAME_LENGTH*sizeof(float));
    memset(p->gFFTworksp, 0, 2*MAX_FRAME_LENGTH*sizeof(float));
    memset(p->gLastPhase, 0, (MAX_FRAME_LENGTH/2+1)*sizeof(float));
    memset(p->gSumPhase, 0, (MAX_FRAME_LENGTH/2+1)*sizeof(float));
    memset(p->gOutputAccum, 0, 2*MAX_FRAME_LENGTH*sizeof(float));
    memset(p->gAnaFreq, 0, MAX_FRAME_LENGTH*sizeof(float));
    memset(p->gAnaMagn, 0, MAX_FRAME_LENGTH*sizeof(float));

    return SP_OK;
}

void smbpitchshift_compute(smbpitchshift *p, float shift, long numSampsToProcess, float *indata, float *outdata)
/*
    Routine smbPitchShift(). See top of file for explanation
    Purpose: doing pitch shifting while maintaining duration using the Short
    Time Fourier Transform.
    Author: (c)1999-2015 Stephan M. Bernsee <s.bernsee [AT] zynaptiq [DOT] com>
*/
{
    double magn, phase, tmp, window, real, imag;
    long index, i, k, qpd;

    /* main processing loop */
    for (i = 0; i < numSampsToProcess; i++){

        /* As long as we have not yet collected enough data just read in */
        p->gInFIFO[p->gRover] = indata[i];
        outdata[i] = p->gOutFIFO[p->gRover - p->inFifoLatency];
        p->gRover++;

        /* now we have enough data for processing */
        if (p->gRover >= p->fftFrameSize) {
           p->gRover = p->inFifoLatency;

            /* do windowing and re,im interleave */
            for (int k = 0; k < p->fftFrameSize; k++) {
                window = -.5*cos(2.*M_PI*(double)k/(double)p->fftFrameSize)+.5;
                p->gFFTworksp[2*k] = p->gInFIFO[k] * window;
                p->gFFTworksp[2*k+1] = 0.;
            }


            /* ***************** ANALYSIS ******************* */
            /* do transform */
            smbFft(p->gFFTworksp, p->fftFrameSize, -1);

            /* this is the analysis step */
            for (k = 0; k <= p->fftFrameSize2; k++) {

                /* de-interlace FFT buffer */
                real = p->gFFTworksp[2*k];
                imag = p->gFFTworksp[2*k+1];

                /* compute magnitude and phase */
                magn = 2.*sqrt(real*real + imag*imag);
                phase = atan2(imag,real);

                /* compute phase difference */
                tmp = phase - p->gLastPhase[k];
                p->gLastPhase[k] = phase;

                /* subtract expected phase difference */
                tmp -= (double)k*p->expct;

                /* map delta phase into +/- Pi interval */
                qpd = tmp/M_PI;
                if (qpd >= 0) qpd += qpd&1;
                else qpd -= qpd&1;
                tmp -= M_PI*(double)qpd;

                /* get deviation from bin frequency from the +/- Pi interval */
                tmp = p->osamp*tmp/(2.*M_PI);

                /* compute the k-th partials' true frequency */
                tmp = (double)k*p->freqPerBin + tmp*p->freqPerBin;

                /* store magnitude and true frequency in analysis arrays */
                p->gAnaMagn[k] = magn;
                p->gAnaFreq[k] = tmp;

            }

            /* ***************** PROCESSING ******************* */
            /* this does the actual pitch shifting */
            memset(p->gSynMagn, 0, p->fftFrameSize*sizeof(float));
            memset(p->gSynFreq, 0, p->fftFrameSize*sizeof(float));
            for (k = 0; k <= p->fftFrameSize2; k++) {
                index = k*shift;
                if (index <= p->fftFrameSize2) {
                    p->gSynMagn[index] += p->gAnaMagn[k];
                    p->gSynFreq[index] = p->gAnaFreq[k] * shift;
                }
            }

            /* ***************** SYNTHESIS ******************* */
            /* this is the synthesis step */
            for (k = 0; k <= p->fftFrameSize2; k++) {

                /* get magnitude and true frequency from synthesis arrays */
                magn = p->gSynMagn[k];
                tmp = p->gSynFreq[k];

                /* subtract bin mid frequency */
                tmp -= (double)k*p->freqPerBin;

                /* get bin deviation from freq deviation */
                tmp /= p->freqPerBin;

                /* take osamp into account */
                tmp = 2.*M_PI*tmp/p->osamp;

                /* add the overlap phase advance back in */
                tmp += (double)k*p->expct;

                /* accumulate delta phase to get bin phase */
                p->gSumPhase[k] += tmp;
                phase = p->gSumPhase[k];

                /* get real and imag part and re-interleave */
                p->gFFTworksp[2*k] = magn*cos(phase);
                p->gFFTworksp[2*k+1] = magn*sin(phase);
            }

            /* zero negative frequencies */
            for (k = p->fftFrameSize+2; k < 2*p->fftFrameSize; k++) p->gFFTworksp[k] = 0.;

            /* do inverse transform */
            smbFft(p->gFFTworksp, p->fftFrameSize, 1);

            /* do windowing and add to output accumulator */
            for(k=0; k < p->fftFrameSize; k++) {
                window = -.5*cos(2.*M_PI*(double)k/(double)p->fftFrameSize)+.5;
                p->gOutputAccum[k] += 2.*window*p->gFFTworksp[2*k]/(p->fftFrameSize2*p->osamp);
            }
            for (k = 0; k < p->stepSize; k++) p->gOutFIFO[k] = p->gOutputAccum[k];

            /* shift accumulator */
            memmove(p->gOutputAccum, p->gOutputAccum+p->stepSize, p->fftFrameSize*sizeof(float));

            /* move input FIFO */
            for (k = 0; k < p->inFifoLatency; k++) p->gInFIFO[k] = p->gInFIFO[k+p->stepSize];
        }
    }
}

// -----------------------------------------------------------------------------------------------------------------


void smbFft(float *fftBuffer, long fftFrameSize, long sign)
/*
    FFT routine, (C)1996 S.M.Bernsee. Sign = -1 is FFT, 1 is iFFT (inverse)
    Fills fftBuffer[0...2*fftFrameSize-1] with the Fourier transform of the
    time domain data in fftBuffer[0...2*fftFrameSize-1]. The FFT array takes
    and returns the cosine and sine parts in an interleaved manner, ie.
    fftBuffer[0] = cosPart[0], fftBuffer[1] = sinPart[0], asf. fftFrameSize
    must be a power of 2. It expects a complex input signal (see footnote 2),
    ie. when working with 'common' audio signals our input signal has to be
    passed as {in[0],0.,in[1],0.,in[2],0.,...} asf. In that case, the transform
    of the frequencies of interest is in fftBuffer[0...fftFrameSize].
*/
{
    float wr, wi, arg, *p1, *p2, temp;
    float tr, ti, ur, ui, *p1r, *p1i, *p2r, *p2i;
    long i, bitm, j, le, le2, k;

    for (i = 2; i < 2*fftFrameSize-2; i += 2) {
        for (bitm = 2, j = 0; bitm < 2*fftFrameSize; bitm <<= 1) {
            if (i & bitm) j++;
            j <<= 1;
        }
        if (i < j) {
            p1 = fftBuffer+i; p2 = fftBuffer+j;
            temp = *p1; *(p1++) = *p2;
            *(p2++) = temp; temp = *p1;
            *p1 = *p2; *p2 = temp;
        }
    }
    for (k = 0, le = 2; k < (long)(log(fftFrameSize)/log(2.)+.5); k++) {
        le <<= 1;
        le2 = le>>1;
        ur = 1.0;
        ui = 0.0;
        arg = M_PI / (le2>>1);
        wr = cos(arg);
        wi = sign*sin(arg);
        for (j = 0; j < le2; j += 2) {
            p1r = fftBuffer+j; p1i = p1r+1;
            p2r = p1r+le2; p2i = p2r+1;
            for (i = j; i < 2*fftFrameSize; i += le) {
                tr = *p2r * ur - *p2i * ui;
                ti = *p2r * ui + *p2i * ur;
                *p2r = *p1r - tr; *p2i = *p1i - ti;
                *p1r += tr; *p1i += ti;
                p1r += le; p1i += le;
                p2r += le; p2i += le;
            }
            tr = ur*wr - ui*wi;
            ui = ur*wi + ui*wr;
            ur = tr;
        }
    }
}


// -----------------------------------------------------------------------------------------------------------------

/*

    12/12/02, smb

    PLEASE NOTE:

    There have been some reports on domain errors when the atan2() function was used
    as in the above code. Usually, a domain error should not interrupt the program flow
    (maybe except in Debug mode) but rather be handled "silently" and a global variable
    should be set according to this error. However, on some occasions people ran into
    this kind of scenario, so a replacement atan2() function is provided here.

    If you are experiencing domain errors and your program stops, simply replace all
    instances of atan2() with calls to the smbAtan2() function below.

*/


double smbAtan2(double x, double y)
{
  double signx;
  if (x > 0.) signx = 1.;
  else signx = -1.;

  if (x == 0.) return 0.;
  if (y == 0.) return signx * M_PI / 2.;

  return atan2(x, y);
}
