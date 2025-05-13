// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import SoundpipeAudioKit
import XCTest
import AVFoundation

class TalkboxTests: XCTestCase {
    func testTalkbox() {
        let engine = AudioEngine()
        
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let source = AudioPlayer(url: url)!
        
        // Excitation/carrier (harmonically rich signal)
        let excitation = DynamicOscillator(waveform: Table(.sawtooth), frequency: 220, amplitude: 1.0)
        
        // Create talkbox with both signals
        let talkbox = Talkbox(source, excitation: excitation)
        
        engine.output = talkbox
        
        let audio = engine.startTest(totalDuration: 5.0)
        
        // Start both signals
        source.play()
        excitation.play()

        audio.append(engine.render(duration: 5.0))
        
        testMD5(audio)
    }
}
