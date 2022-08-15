// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AudioKitEX
import AVFoundation
import CSoundpipeAudioKit

/// This module will perform partitioned convolution on an input signal using an
/// ftable as an impulse response.
///
public class Convolution: Node {
    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(effect: "conv")

    // MARK: - Parameters

    fileprivate var impulseResponseFileURL: CFURL
    fileprivate var partitionLength: Int = 2048

    // MARK: - Initialization

    /// Initialize this convolution node
    ///
    /// - Parameters:
    ///   - partitionLength: Partition length (in samples). Must be a power of 2.
    ///     Lower values will add less latency, at the cost of requiring more CPU power.
    ///
    public init(_ input: Node,
                impulseResponseFileURL: URL,
                partitionLength: Int = 2048)
    {
        self.input = input
        self.impulseResponseFileURL = impulseResponseFileURL as CFURL
        self.partitionLength = partitionLength

        setupParameters()
        akConvolutionSetPartitionLength(au.dsp, Int32(partitionLength))

        readAudioFile()
        start()
    }

    private func readAudioFile() {
        Exit: do {
            var error: NSError?

            guard let file = try? AVAudioFile(forReading: impulseResponseFileURL as URL) else {
                Log("Error = Reading impulse file")
                break Exit
            }

            guard let inputBuffer = try? AVAudioPCMBuffer(file: file) else {
                Log("Error = Reading impulse response file")
                break Exit
            }

            // Output Format
            guard let clientFormat = AVAudioFormat(
                commonFormat: .pcmFormatFloat32,
                sampleRate: Settings.sampleRate,
                channels: file.fileFormat.channelCount,
                interleaved: false
            ) else {
                Log("Error = Output format error")
                break Exit
            }

            let frameCapacity = Double(file.length) / file.processingFormat.sampleRate * Settings.sampleRate
            guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: clientFormat, frameCapacity: AVAudioFrameCount(frameCapacity)) else {
                Log("Error = Output buffer creation error")
                break Exit
            }

            guard let converter = AVAudioConverter(from: file.processingFormat, to: clientFormat) else {
                Log("Error = Converter initialization error")
                break Exit
            }

            let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
                outStatus.pointee = AVAudioConverterInputStatus.haveData
                return inputBuffer
            }

            converter.convert(to: outputBuffer, error: &error, withInputFrom: inputBlock)

            if error != nil {
                Log(error!.localizedDescription)
                break Exit
            }

            let samples = outputBuffer.toFloatChannelData()!

            for (index, data) in samples.enumerated() {
                au.setWavetable(data: data, size: data.count, index: index)
            }
        }
    }
}
