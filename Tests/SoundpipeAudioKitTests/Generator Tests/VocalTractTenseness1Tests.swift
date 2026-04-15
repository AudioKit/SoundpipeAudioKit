// Regression guard for https://github.com/AudioKit/SoundpipeAudioKit/issues/37
// (tenseness=1 reportedly silencing the generator). The bug no longer repros
// in offline render; these tests assert the boundary values still produce audio.

import AudioKit
import AVFoundation
import SoundpipeAudioKit
import XCTest

class VocalTractTenseness1Tests: XCTestCase {
    func testTensenessZeroToOneSnap() {
        assertAudible(setup: { $0.tenseness = 0.0 }, transition: { $0.tenseness = 1.0 })
    }

    func testTensenessZeroToOneRamp() {
        assertAudible(setup: { $0.tenseness = 0.0 },
                      transition: { $0.$tenseness.ramp(to: 1.0, duration: 0.1) })
    }

    func testTensenessStartsAtOne() {
        assertAudible(setup: { $0.tenseness = 1.0 }, transition: { _ in })
    }

    func testTensenessOneToZero() {
        assertAudible(setup: { $0.tenseness = 1.0 }, transition: { $0.tenseness = 0.0 })
    }

    private func assertAudible(setup: (VocalTract) -> Void,
                               transition: (VocalTract) -> Void,
                               file: StaticString = #filePath,
                               line: UInt = #line) {
        let engine = AudioEngine()
        let vocalTract = VocalTract()
        setup(vocalTract)
        engine.output = vocalTract

        let audio = engine.startTest(totalDuration: 2.0)
        vocalTract.start()
        audio.append(engine.render(duration: 1.0))
        transition(vocalTract)
        let after = engine.render(duration: 1.0)
        audio.append(after)
        engine.stop()

        XCTAssertGreaterThan(rms(of: after), 1e-5, "near-silent output", file: file, line: line)
        XCTAssertFalse(hasNonFinite(after), "NaN/Inf in output", file: file, line: line)
    }

    private func rms(of buffer: AVAudioPCMBuffer) -> Float {
        guard let data = buffer.floatChannelData else { return 0 }
        let frames = Int(buffer.frameLength)
        let channels = Int(buffer.format.channelCount)
        var sumSq: Double = 0
        for ch in 0 ..< channels {
            for i in 0 ..< frames {
                let s = Double(data[ch][i])
                if s.isFinite { sumSq += s * s }
            }
        }
        let n = Double(frames * channels)
        return n > 0 ? Float((sumSq / n).squareRoot()) : 0
    }

    private func hasNonFinite(_ buffer: AVAudioPCMBuffer) -> Bool {
        guard let data = buffer.floatChannelData else { return false }
        let frames = Int(buffer.frameLength)
        for ch in 0 ..< Int(buffer.format.channelCount) {
            for i in 0 ..< frames where !data[ch][i].isFinite { return true }
        }
        return false
    }
}
