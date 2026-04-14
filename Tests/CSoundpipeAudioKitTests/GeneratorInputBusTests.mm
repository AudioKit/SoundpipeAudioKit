#import <XCTest/XCTest.h>
#import <CSoundpipeAudioKit.h>
#import <DSPBase.h>

/// Regression tests for https://github.com/AudioKit/SoundpipeAudioKit/issues/46
///
/// Generators have no audio input bus. If a generator DSP inherits the
/// SoundpipeDSPBase default of `inputBusCount=1`, its bypass path in
/// `DSPBase::processOrBypass` neither zeroes the output (non-empty
/// inputBufferLists skips that branch) nor can it safely copy input
/// (there is no connected input), and with `canProcessInPlace=false`
/// it dereferences an uninitialized buffer and crashes.
///
/// Every generator in this package must therefore be constructed with
/// `inputBusCount=0`.
@interface GeneratorInputBusTests : XCTestCase
@end

@implementation GeneratorInputBusTests

static OSType fourCC(const char *s) {
    return (OSType)((uint8_t)s[0] << 24 | (uint8_t)s[1] << 16 | (uint8_t)s[2] << 8 | (uint8_t)s[3]);
}

- (void)assertGeneratorCode:(const char *)code {
    DSPRef dsp = akCreateDSP(fourCC(code));
    XCTAssertTrue(dsp != NULL, @"Failed to create DSP '%s'", code);
    XCTAssertEqual(inputBusCountDSP(dsp), 0UL,
                   @"Generator '%s' must have inputBusCount=0", code);
    deleteDSP(dsp);
}

- (void)testPhaseLockedVocoderIsGenerator {
    [self assertGeneratorCode:"minc"];
}

- (void)testAllGeneratorsHaveNoInputBus {
    // Codes from AK_REGISTER_DSP in Sources/CSoundpipeAudioKit/Generators/*.mm
    const char *codes[] = {
        "bron", // BrownianNoise
        "csto", // DynamicOscillator
        "fosc", // FMOscillator
        "mbar", // MetalBar
        "morf", // MorphingOscillator
        "oscl", // Oscillator
        "pdho", // PhaseDistortionOscillator
        "minc", // PhaseLockedVocoder
        "pink", // PinkNoise
        "pluk", // PluckedString
        "pwmo", // PWMOscillator
        "vocw", // VocalTract
        "wnoz", // WhiteNoise
    };
    for (const char *code : codes) {
        [self assertGeneratorCode:code];
    }
}

@end
