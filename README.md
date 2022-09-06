<div align=center>
<img src="https://github.com/AudioKit/Cookbook/raw/main/Cookbook/Cookbook/Assets.xcassets/audiokit-icon.imageset/audiokit-icon.png" width="20%"/>

# Soundpipe AudioKit

[![Build Status](https://github.com/AudioKit/SoundpipeAudioKit/workflows/CI/badge.svg)](https://github.com/AudioKit/SoundpipeAudioKit/actions?query=workflow%3ACI)
[![License](https://img.shields.io/github/license/AudioKit/SoundpipeAudioKit)](https://github.com/AudioKit/SoundpipeAudioKit/blob/main/LICENSE)
[![Swift Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FAudioKit%2FSoundpipeAudioKit%2Fbadge%3Ftype%3Dswift-versions&label=)](https://swiftpackageindex.com/AudioKit/SoundpipeAudioKit)
 [![Platform Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FAudioKit%2FSoundpipeAudioKit%2Fbadge%3Ftype%3Dplatforms&label=)](https://swiftpackageindex.com/AudioKit/SoundpipeAudioKit)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)
[![Twitter Follow](https://img.shields.io/twitter/follow/AudioKitPro.svg?style=social)](https://twitter.com/AudioKitPro)

</div>

This extension to AudioKit has the majority of old versions of AudioKit's DSP including oscillators, physical models, filters, reverbs and more.

## Examples

See the [AudioKit Cookbook](https://github.com/AudioKit/Cookbook/) for examples.

## Installation

Install with Swift Package Manager.

## Targets

| Name               | Description                                                 | Language      |
|--------------------|-------------------------------------------------------------|---------------|
| SoundpipeAudioKit  | API for using Soundpipe-powered Audio Units                 | Swift         |
| CSoundpipeAudioKit | Audio Units for the Soundpipe DSP                           | Objective-C++ |
| Soundpipe          | Low-level DSP for oscillators, physical models, and effects | C             |

## Generators / Instruments

* [Brownian Noise](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/browniannoise)
* [Drip](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/drip)
* [Dynamic Oscillator](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/dynamicoscillator)
* [FM Oscillator](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/fmoscillator)
* [Metal Bar](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/metalbar)
* [Morphing Oscillator](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/morphingoscillator)
* [Oscillator](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/oscillator)
* [PWM Oscillator](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/pwmoscillator)
* [Phase Distortion Oscillator](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/phasedistortionoscillator)
* [Phase Locked Vocoder](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/phaselockedvocoder)
* [Pink Noise](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/pinknoise)
* [Plucked String](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/pluckedstring)
* [White Noise](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/whitenoise)
* [Vocal Tract](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/vocaltract)

## Effects / Filters

* [Amplitude Envelope](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/amplitudeenvelope)
* [Auto Panner](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/autopanner)
* [Auto Wah](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/autowah)
* [Balancer](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/balancer)
* [Band Pass Butterworth Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/bandpassbutterworthfilter)
* [Band Reject Butterworth Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/bandrejectbutterworthfilter)
* [Bit Crusher](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/bitcrusher)
* [Chowning Reverb](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/chowningreverb)
* [Clipper](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/clipper)
* [CombFilter Reverb](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/combfilterreverb)
* [Convolution](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/convolution)
* [Costello Reverb](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/costelloreverb)
* [DC Block](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/dcblock)
* [Dynamic Range Compressor](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/dynamicrangecompressor)
* [Equalizer Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/equalizerfilter)
* [Flat Frequency ResponseReverb](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/flatfrequencyresponsereverb)
* [Formant Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/formantfilter)
* [High Pass Butterworth Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/highpassbutterworthfilter)
* [High Shelf Parametric Equalizer Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/highshelfparametricequalizerfilter)
* [Korg Low Pass Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/korglowpassfilter)
* [Low Pass Butterworth Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/lowpassbutterworthfilter)
* [Low Shelf Parametric Equalizer Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/lowshelfparametricequalizerfilter)
* [Modal Resonance Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/modalresonancefilter)
* [Moog Ladder](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/moogladder)
* [Panner](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/panner)
* [Peaking Parametric Equalizer Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/peakingparametricequalizerfilter)
* [Phaser](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/phaser)
* [Pitch Shifter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/pitchshifter)
* [Resonant Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/resonantfilter)
* [Roland TB303 Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/rolandtb303filter)
* [String Resonator](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/stringresonator)
* [Tanh Distortion](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/tanhdistortion)
* [Three Pole Lowpass Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/threepolelowpassfilter)
* [Tone Complement Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/tonecomplementfilter)
* [Tone Filter](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/tonefilter)
* [Tremolo](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/tremolo)
* [Variable Delay](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/variabledelay)
* [Zita Reverb](https://audiokit.io/SoundpipeAudioKit/documentation/soundpipeaudiokit/zitareverb)