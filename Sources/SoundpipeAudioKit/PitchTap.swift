// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFoundation
import CSoundpipeAudioKit

/// Tap to do pitch tracking on any node.
/// start() will add the tap, and stop() will remove it.
public class PitchTap: BaseTap {
    private var pitch: [Float] = [0, 0]
    private var amp: [Float] = [0, 0]
    private var trackers: [PitchTrackerRef] = []

    /// Detected amplitude (average of left and right channels)
    public var amplitude: Float {
        return amp.reduce(0, +) / 2
    }

    /// Detected frequency of left channel
    public var leftPitch: Float {
        return pitch[0]
    }

    /// Detected frequency of right channel
    public var rightPitch: Float {
        return pitch[1]
    }

    /// Callback type
    public typealias Handler = ([Float], [Float]) -> Void

    private var handler: Handler = { _, _ in }

    /// Initialize the pitch tap
    ///
    /// - Parameters:
    ///   - input: Node to analyze
    ///   - bufferSize: Size of buffer to analyze
    ///   - handler: Callback to call on each analysis pass
    public init(_ input: Node, bufferSize: UInt32 = 4096, handler: @escaping Handler) {
        self.handler = handler
        super.init(input, bufferSize: bufferSize, callbackQueue: DispatchQueue.main)
    }

    deinit {
        for tracker in trackers {
            akPitchTrackerDestroy(tracker)
        }
    }

    /// Stop detecting pitch
    override open func stop() {
        super.stop()
        for i in 0 ..< pitch.count {
            pitch[i] = 0.0
        }
    }

    /// Override this method to handle Tap in derived class
    /// - Parameters:
    ///   - buffer: Buffer to analyze
    ///   - time: Unused in this case
    override public func doHandleTapBlock(buffer: AVAudioPCMBuffer, at _: AVAudioTime) {
        guard let floatData = buffer.floatChannelData else { return }
        let channelCount = Int(buffer.format.channelCount)
        let length = UInt(buffer.frameLength)
        while trackers.count < channelCount {
            trackers.append(akPitchTrackerCreate(UInt32(Settings.audioFormat.sampleRate), 4096, 20))
        }

        while amp.count < channelCount {
            amp.append(0)
            pitch.append(0)
        }

        // n is the channel
        for n in 0 ..< channelCount {
            let data = floatData[n]

            akPitchTrackerAnalyze(trackers[n], data, UInt32(length))

            var a: Float = 0
            var f: Float = 0
            akPitchTrackerGetResults(trackers[n], &a, &f)
            amp[n] = a
            pitch[n] = f
        }
        handler(pitch, amp)
    }
}
