// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import SoundpipeAudioKit
import XCTest

class VocoderTests: XCTestCase {
    func testVocoder() {
        let engine = AudioEngine()
        
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let source = AudioPlayer(url: url)!
        
        // Excitation/carrier (harmonically rich signal)
        let excitation = DynamicOscillator(waveform: Table(.sawtooth), frequency: 110, amplitude: 1.0)
        excitation.$frequency.ramp(to: 440, duration: 5.0)
        
        // Create vocoder with both signals
        let vocoder = Vocoder(source, excitation: excitation)
        vocoder.$attackTime.ramp(from: 0.1, to: 0.5, duration: 5.0)
        vocoder.$releaseTime.ramp(from: 0.1, to: 0.5, duration: 5.0)
        vocoder.$bandwidthRatio.ramp(from: 0.1, to: 2.0, duration: 5.0)

        engine.output = vocoder
        
        let audio = engine.startTest(totalDuration: 5.0)
        
        // Start both signals
        source.play()
        excitation.play()

        audio.append(engine.render(duration: 5.0))
        
        testMD5(audio)
    }
}
