import AVFoundation
import XCTest

extension XCTestCase {
    func testMD5(_ buffer: AVAudioPCMBuffer) {
        let localMD5 = buffer.md5
        let name = description
        XCTAssert(validatedMD5s[name] == buffer.md5, "\nFAILEDMD5 \"\(name)\": \"\(localMD5)\",")
    }
}

let validatedMD5s: [String: String] = [
    "-[AmplitudeEnvelopeTests testAttack]": "e3d436a1fd2c98899719297be9d254f4",
    "-[AmplitudeEnvelopeTests testDecay]": "4ec2b831d4ab4db0740eb81bc438d67c",
    "-[AmplitudeEnvelopeTests testDefault]": "93963885375826b81930ae8e051c8771",
    "-[AmplitudeEnvelopeTests testDoubleStop]": "79d27434a64c93403c0ab389336f0c89",
    "-[AmplitudeEnvelopeTests testParameters]": "874d2924a1e95c66bf521d4bb978c904",
    "-[AmplitudeEnvelopeTests testRelease]": "79d27434a64c93403c0ab389336f0c89",
    "-[AmplitudeEnvelopeTests testSustain]": "c53a7d6ee64207f9838bddde166a985e",
    "-[BalancerTests testDefault]": "23172bb688c4aec315a606c8c2ed43d0",
    "-[ConvolutionTests testConvolution]": "987bc2c2ff875eed03b0144e9f46ac69",
    "-[ConvolutionTests testStereoConvolution]": "77a01b54f6c45814bbfdb7349a402953",
    "-[DiodeLadderFilterTests testBypass]": "0b24695aea401ae078ddf40047db2e00",
    "-[DiodeLadderFilterTests testParameterRamping]": "85b3781c3276eb2c8ab82742951bc91b",
    "-[DiodeLadderFilterTests testReset]": "923bc50f5a93841bfba618778e95d337",
    "-[DiodeLadderFilterTests testSampleRateChange]": "ec97ea2b614f085202714c04f5dc474b",
    "-[DynamicOscillatorTests testAmpitude]": "86497903abc5f53ef15fecf5660709bb",
    "-[DynamicOscillatorTests testDefault]": "7a3dc1fdc7f7c4d113ba9d1119143e67",
    "-[DynamicOscillatorTests testDetuningMultiplier]": "b9caf0d0e39aa5bf6073f861ff7cdd23",
    "-[DynamicOscillatorTests testDetuningOffset]": "ee8fc07672ed022a4c86146b18a38aca",
    "-[DynamicOscillatorTests testFrequency]": "33fc3ddee3e17226ddfc976f080b7e00",
    "-[DynamicOscillatorTests testParametersSetAfterInit]": "7ae6c2133daa0b06f24c29d979424e14",
    "-[DynamicOscillatorTests testParameters]": "7ae6c2133daa0b06f24c29d979424e14",
    "-[DynamicOscillatorTests testRamping]": "5336499be4b3eb5284e1d929c612341b",
    "-[DynamicOscillatorTests testNewAutomationFrequency]": "71db4b3c3f16a50f282eea8159332c1b",
    "-[DynamicOscillatorTests testNewAutomationAmplitude]": "23b732534e14d8c83ae43a6a835c3846",
    "-[DynamicOscillatorTests testNewAutomationMultiple]": "c3bffa8dd27eec5ccb9efe68148e7e45",
    "-[DynamicOscillatorTests testNewAutomationDelayed]": "53c9a85da69da2da955709b7f0ea76d4",
    "-[DynamicOscillatorTests testSetWavetable]": "f03616a8900da6157a01f549269d43f5",
    "-[DynamicOscillatorTests testGetWavetableValues]": "bb94a34a01bd3423eb417d35f261ff52",
    "-[DynamicOscillatorTests testWavetableUpdateHandler]": "bb94a34a01bd3423eb417d35f261ff52",
    "-[FlatFrequencyResponseReverbTests testLoopDuration]": "eba3dd779fb28c702b71100cd3ea76dc",
    "-[MetalBarTests testDefault]": "a16bd31d73975ede645b815e5e057827",
    "-[OscillatorAutomationTests testNewAutomationAmplitude]": "23b732534e14d8c83ae43a6a835c3846",
    "-[OscillatorAutomationTests testNewAutomationDelayed]": "049edbef1e0ea22d8c70dccf4aa2c9de",
    "-[OscillatorAutomationTests testNewAutomationFrequency]": "71db4b3c3f16a50f282eea8159332c1b",
    "-[OscillatorAutomationTests testNewAutomationMultiple]": "c3bffa8dd27eec5ccb9efe68148e7e45",
    "-[OscillatorAutomationTests testAutomationAfterDelayedConnection]": "0e0b2ee26c54b5c746873a57457b13c9",
    "-[OscillatorAutomationTests testDelayedAutomation]": "dba1932564632c0f3ef160d43c4d0f2f",
    "-[PhaseLockedVocoderTests testDefault]": "ed14b3d5d507a3dba7d891e73e52da25",
    "-[PitchTapTests testBasic]": "8f079dbbea346339584b464a767f90f8",
    "-[PluckedStringTests testDefault]": "727861aac871f5169de7da9c134a0102",
    "-[TalkboxTests testTalkbox]": "316ef6638793f5fb6ec43fae1919ccff",
    "-[VocoderTests testVocoder]": "3836def448fed8ac901b179e943e6922",
    "-[VibratoTests testVibrato]": "4bad4a6d951683cf6745a79b96b6aae2",
    "-[VibratoTests testParameterSweep]": "cc3613847ed31d6566bbd4f6907e26e5",
    "-[PitchCorrectTests testPitchCorrect]": "914c45afe046912fe58e875728ffb88c",
    "-[EnsembleTests testAllVoicesActive]": "524b59ceb689d76e0ec5af4d8c2cddeb",
    "-[EnsembleTests testArrayInitializer]": "7ea6bf4e50e6463b468df5984fff4042",
    "-[EnsembleTests testDominantSeventhChord]": "254dede98cc20371240a0e0a74741db5",
    "-[EnsembleTests testDrySignalOnly]": "f0096d990a5621665c5378ce39c104b5",
    "-[EnsembleTests testEmptyArrays]": "68938c8097d4347c6acbe7b7f18fd6b6",
    "-[EnsembleTests testMajorChord]": "f8bb616ea1b9e7caffd3e7ff3d3da163",
    "-[EnsembleTests testMicrotones]": "e1b58fcb2e37b5108f1a53a07a0d122c",
    "-[EnsembleTests testParameterAutomation]": "9071f70f9536ecf746e810aa676d8544",
    "-[EnsembleTests testSingleVoice]": "8d3e03cd3ff04f5d299f0399e1bdd4e7"
]
