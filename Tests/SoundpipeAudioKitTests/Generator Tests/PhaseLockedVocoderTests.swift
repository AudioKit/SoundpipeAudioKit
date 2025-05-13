import AudioKit
import AVFoundation
import SoundpipeAudioKit
import XCTest

class PhaseLockedVocoderTests: XCTestCase {
    // Because SPM doesn't support resources yet, render out a test file.
    func generateTestFile() -> URL {
        let osc = Oscillator(waveform: Table(.triangle))
        let engine = AudioEngine()
        engine.output = osc
        osc.start()
        osc.$frequency.ramp(to: 880, duration: 1.0)

        let mgr = FileManager.default
        let url = mgr.temporaryDirectory.appendingPathComponent("test.aiff")
        try? mgr.removeItem(at: url)
        let file = try! AVAudioFile(forWriting: url, settings: Settings.audioFormat.settings)

        try! engine.renderToFile(file, duration: 1)
        print("rendered test file to \(url)")

        return url
    }

    func testDefault() {
        let url = generateTestFile()

        XCTAssertNotNil(url)

        let file = try! AVAudioFile(forReading: url)

        let engine = AudioEngine()
        let vocoder = PhaseLockedVocoder(file: file)
        engine.output = vocoder

        let audio = engine.startTest(totalDuration: 2.0)
        vocoder.$position.ramp(to: 0.5, duration: 0.5)
        audio.append(engine.render(duration: 1.0))
        vocoder.$position.ramp(to: 0, duration: 0.5)
        audio.append(engine.render(duration: 1.0))

        engine.stop()

        testMD5(audio)
    }

    func testReset() {
        let url = generateTestFile()
        XCTAssertNotNil(url)

        guard let file = try? AVAudioFile(forReading: url) else {
            XCTFail("Couldn't load test file")
            return
        }

        let engine = AudioEngine()
        let vocoder = PhaseLockedVocoder(file: file)
        engine.output = vocoder

        // Start the engine and render some audio
        let audio = engine.startTest(totalDuration: 2.0)
        vocoder.$position.ramp(to: 0.5, duration: 0.5)
        audio.append(engine.render(duration: 1.0))

        // Get initial memory usage
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        var kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        XCTAssertEqual(kerr, KERN_SUCCESS)
        let initialMemory = info.resident_size

        // Reset the vocoder multiple times to stress test memory management
        for _ in 0 ... 1000 {
            vocoder.reset()
        }

        // Get final memory usage
        kerr = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        XCTAssertEqual(kerr, KERN_SUCCESS)
        let finalMemory = info.resident_size

        // Calculate memory growth
        let memoryGrowth = finalMemory - initialMemory
        XCTAssertLessThan(memoryGrowth, 1_000_000, "Memory leak detected: Memory grew by \(memoryGrowth) bytes")

        // Continue rendering after reset
        vocoder.$position.ramp(to: 0, duration: 0.5)
        audio.append(engine.render(duration: 1.0))

        engine.stop()
    }
}
