// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import SoundpipeAudioKit
import XCTest

class PitchShifterTests: XCTestCase {
    func testPitchShifter() {
        let engine = AudioEngine()
        let input = Oscillator()
        let shifter = PitchShifter(input)
        shifter.shift = 7
        engine.output = Mixer(input, shifter)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        audio.audition()
    }
}
