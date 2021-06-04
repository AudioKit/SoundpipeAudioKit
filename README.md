<div align=center>
<img src="https://github.com/AudioKit/Cookbook/raw/main/Cookbook/Cookbook/Assets.xcassets/audiokit-icon.imageset/audiokit-icon.png" width="20%"/>

# Soundpipe AudioKit

[![Build Status](https://github.com/AudioKit/SoundpipeAudioKit/workflows/CI/badge.svg)](https://github.com/AudioKit/SoundpipeAudioKit/actions?query=workflow%3ACI)
[![License](https://img.shields.io/github/license/AudioKit/SoundpipeAudioKit)](https://github.com/AudioKit/SoundpipeAudioKit/blob/main/LICENSE)
[![Platform](https://img.shields.io/cocoapods/p/AudioKit)](https://github.com/AudioKit/AudioKit/wiki)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)
[![Twitter Follow](https://img.shields.io/twitter/follow/AudioKitPro.svg?style=social)](https://twitter.com/AudioKitPro)

</div>

This extension to AudioKit has the majority of old versions of AudioKit's DSP including oscillators, physical models, filters, reverbs and more.

## Examples

See the [AudioKit Cookbook](https://github.com/AudioKit/Cookbook/) for examples.

## Installation

Use Swift Package Manager and point to the URL: `https://github.com/AudioKit/SoundpipeAudioKit/`

## Targets

| Name               | Description                                                 | Language      |
|--------------------|-------------------------------------------------------------|---------------|
| SoundpipeAudioKit  | API for using Soundpipe-powered Audio Units                 | Swift         |
| CSoundpipeAudioKit | Audio Units for the Soundpipe DSP                           | Objective-C++ |
| Soundpipe          | Low-level DSP for oscillators, physcial models, and effects | C             |

## Generators / Instruments

* [Brownian Noise](https://github.com/AudioKit/SoundpipeAudioKit/wiki/BrownianNoise)
* [Drip](https://github.com/AudioKit/SoundpipeAudioKit/wiki/Drip)
* [Dynamic Oscillator](https://github.com/AudioKit/SoundpipeAudioKit/wiki/DynamicOscillator)
* [FM Oscillator](https://github.com/AudioKit/SoundpipeAudioKit/wiki/FMOscillator)
* [Metal Bar](https://github.com/AudioKit/SoundpipeAudioKit/wiki/MetalBar)
* [Morphing Oscillator](https://github.com/AudioKit/SoundpipeAudioKit/wiki/MorphingOscillator)
* [Oscillator](https://github.com/AudioKit/SoundpipeAudioKit/wiki/Oscillator)
* [PWM Oscillator](https://github.com/AudioKit/SoundpipeAudioKit/wiki/PWMOscillator)
* [Phase Distortion Oscillator](https://github.com/AudioKit/SoundpipeAudioKit/wiki/PhaseDistortionOscillator)
* [Phase Locked Vocoder](https://github.com/AudioKit/SoundpipeAudioKit/wiki/PhaseLockedVocoder)
* [Pink Noise](https://github.com/AudioKit/SoundpipeAudioKit/wiki/PinkNoise)
* [Plucked String](https://github.com/AudioKit/SoundpipeAudioKit/wiki/PluckedString)
* [White Noise](https://github.com/AudioKit/SoundpipeAudioKit/wiki/WhiteNoise)
* [Vocal Tract](https://github.com/AudioKit/SoundpipeAudioKit/wiki/VocalTract)

## Effects / Filters

* [AmplitudeEnvelope](https://github.com/AudioKit/SoundpipeAudioKit/wiki/AmplitudeEnvelope)
* [AutoPanner](https://github.com/AudioKit/SoundpipeAudioKit/wiki/AutoPanner)
* [AutoWah](https://github.com/AudioKit/SoundpipeAudioKit/wiki/AutoWah)
* [Balancer](https://github.com/AudioKit/SoundpipeAudioKit/wiki/Balancer)
* [BandPassButterworthFilter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/BandPassButterworthFilter)
* [BandRejectButterworthFilter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/BandRejectButterworthFilter)
* [BitCrusher](https://github.com/AudioKit/SoundpipeAudioKit/wiki/BitCrusher)
* [ChowningReverb](https://github.com/AudioKit/SoundpipeAudioKit/wiki/ChowningReverb)
* [Clipper](https://github.com/AudioKit/SoundpipeAudioKit/wiki/Clipper)
* [CombFilterReverb](https://github.com/AudioKit/SoundpipeAudioKit/wiki/CombFilterReverb)
* [Convolution](https://github.com/AudioKit/SoundpipeAudioKit/wiki/Convolution)
* [CostelloReverb](https://github.com/AudioKit/SoundpipeAudioKit/wiki/CostelloReverb)
* [DCBlock](https://github.com/AudioKit/SoundpipeAudioKit/wiki/DCBlock)
* [DynamicRangeCompressor](https://github.com/AudioKit/SoundpipeAudioKit/wiki/DynamicRangeCompressor)
* [EqualizerFilter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/EqualizerFilter)
* [FlatFrequencyResponseReverb](https://github.com/AudioKit/SoundpipeAudioKit/wiki/FlatFrequencyResponseReverb)
* [FormantFilter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/FormantFilter)
* [HighPassButterworthFilter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/HighPassButterworthFilter)
* [HighShelfParametricEqualizerFilter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/HighShelfParametricEqualizerFilter)
* [KorgLowPassFilter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/KorgLowPassFilter)
* [LowPassButterworthFilter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/LowPassButterworthFilter)
* [LowShelfParametricEqualizerFilter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/LowShelfParametricEqualizerFilter)
* [ModalResonanceFilter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/ModalResonanceFilter)
* [MoogLadder](https://github.com/AudioKit/SoundpipeAudioKit/wiki/MoogLadder)
* [Panner](https://github.com/AudioKit/SoundpipeAudioKit/wiki/Panner)
* [PeakingParametricEqualizerFilter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/PeakingParametricEqualizerFilter)
* [Phaser](https://github.com/AudioKit/SoundpipeAudioKit/wiki/Phaser)
* [PitchShifter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/PitchShifter)
* [ResonantFilter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/ResonantFilter)
* [RolandTB303Filter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/RolandTB303Filter)
* [StringResonator](https://github.com/AudioKit/SoundpipeAudioKit/wiki/StringResonator)
* [TanhDistortion](https://github.com/AudioKit/SoundpipeAudioKit/wiki/TanhDistortion)
* [ThreePoleLowpassFilter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/ThreePoleLowpassFilter)
* [ToneComplementFilter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/ToneComplementFilter)
* [ToneFilter](https://github.com/AudioKit/SoundpipeAudioKit/wiki/ToneFilter)
* [Tremolo](https://github.com/AudioKit/SoundpipeAudioKit/wiki/Tremolo)
* [VariableDelay](https://github.com/AudioKit/SoundpipeAudioKit/wiki/VariableDelay)
* [ZitaReverb](https://github.com/AudioKit/SoundpipeAudioKit/wiki/ZitaReverb)