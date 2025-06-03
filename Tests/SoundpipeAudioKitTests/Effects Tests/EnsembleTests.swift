// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import SoundpipeAudioKit
import XCTest

class EnsembleTests: XCTestCase {
    
    func testMajorChord() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let input = AudioPlayer(url: url)!
        // Create a C major chord: C, E, G (0, 4, 7 semitones)
        let ensemble = Ensemble(input,
                                shifts:[0, 4, 7], pans: [-1, 1],
                                dryWetMix: 1.0)
        ensemble.$shift2.ramp(to: 12, duration: 5.0)
        ensemble.$pan2.ramp(to: -1, duration: 5.0)
        engine.output = ensemble
        let audio = engine.startTest(totalDuration: 5.0)
        input.play()
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }
    
    func testAllVoicesActive() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let input = AudioPlayer(url: url)!
        // Test with all 9 voices active in different pitch shifts
        let ensemble = Ensemble(input,
                              shifts: [-12, -9, -6, -3, 0, 3, 6, 9, 12],
                              pans: [-1, -0.5, -0.25, 0, 0, 0, 0.25, 0.5, 1],
                              dryWetMix: 1.0)
        engine.output = ensemble
        let audio = engine.startTest(totalDuration: 5.0)
        input.play()
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }
    
    func testArrayInitializer() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let input = AudioPlayer(url: url)!
        // Test the array initializer with a C major chord
        let ensemble = Ensemble(input,
                              shifts: [0, 4, 7],
                              pans: [-1, 0, 1],
                              dryWetMix: 1.0)
        engine.output = ensemble
        let audio = engine.startTest(totalDuration: 5.0)
        input.play()
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }
    
    func testEmptyArrays() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let input = AudioPlayer(url: url)!
        // Test with empty arrays (should default to single voice at 0 shift)
        let ensemble = Ensemble(input,
                              shifts: [],
                              pans: [],
                              dryWetMix: 1.0)
        engine.output = ensemble
        let audio = engine.startTest(totalDuration: 5.0)
        input.play()
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }
    
    func testSingleVoice() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let input = AudioPlayer(url: url)!
        // Test with single voice
        let ensemble = Ensemble(input,
                              shifts: [5],
                              pans: [0.5],
                              dryWetMix: 1)
        engine.output = ensemble
        let audio = engine.startTest(totalDuration: 5.0)
        input.play()
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }
    
    func testDominantSeventhChord() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let input = AudioPlayer(url: url)!
        // Test a dominant 7th chord: C, E, G, Bb (0, 4, 7, 10 semitones)
        let ensemble = Ensemble(input,
                              shifts: [0, 4, 7, 10],
                              pans: [-0.5, -0.25, 0.25, 0.5],
                              dryWetMix: 1.0)
        engine.output = ensemble
        let audio = engine.startTest(totalDuration: 5.0)
        input.play()
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }
    
    func testMicrotones() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let input = AudioPlayer(url: url)!
        // Test with microtonal intervals (quarter tones)
        let ensemble = Ensemble(input,
                              shifts: [0, 0.5, 1.0, 1.5, 2.0],
                              pans: [-1, -0.5, 0, 0.5, 1],
                              dryWetMix: 1.0)
        engine.output = ensemble
        let audio = engine.startTest(totalDuration: 5.0)
        input.play()
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }

    
    func testDrySignalOnly() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let input = AudioPlayer(url: url)!
        // Test with completely dry signal
        let ensemble = Ensemble(input,
                              shifts: [0, 12, 24],
                              pans: [-1, 0, 1],
                              dryWetMix: 0.0)
        engine.output = ensemble
        let audio = engine.startTest(totalDuration: 5.0)
        input.play()
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }
    
    func testParameterAutomation() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let input = AudioPlayer(url: url)!
        let ensemble = Ensemble(input,
                              shifts: [0, 4, 7],
                              pans: [-1, 0, 1],
                              dryWetMix: 0.5)
        
        // Test parameter automation
        ensemble.$shift2.ramp(to: 12, duration: 2.0)
        ensemble.$pan2.ramp(to: -1, duration: 2.0)
        ensemble.$dryWetMix.ramp(to: 1.0, duration: 2.0)
        
        engine.output = ensemble
        let audio = engine.startTest(totalDuration: 5.0)
        input.play()
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }

}
