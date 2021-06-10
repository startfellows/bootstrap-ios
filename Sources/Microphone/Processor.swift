//
//  Created by Anton Spivak.
//

import Foundation
import AVFoundation

final class Processor {
    
    enum Error: Swift.Error {
        
        case cantFindLastRecord
        case cantCreateRenderBuffer
        case cantCreateReadBuffer
    }
    
    public init() {}
    
    public func process(inputURL readURL: URL, outputURL writeURL: URL, with effect: Effect?) throws {
        try? FileManager.default.removeItem(at: writeURL)
        
        let renderSize: AVAudioFrameCount = 1024        
        guard let renderFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 44100.0, channels: 2, interleaved: true),
              let renderBuffer = AVAudioPCMBuffer(pcmFormat: renderFormat, frameCapacity: renderSize)
        else {
            throw Error.cantCreateRenderBuffer
        }
        
        let readAudioFile = try AVAudioFile(forReading: readURL)
        let writeAudioFile = try AVAudioFile(forWriting: writeURL, settings: renderFormat.settings, commonFormat: renderFormat.commonFormat, interleaved: renderFormat.isInterleaved)
     
        let audioEngine = AVAudioEngine()
        
        let playerNode = AVAudioPlayerNode()
        audioEngine.attach(playerNode)
        
        effect?.units.forEach({ audioEngine.attach($0) })
    
        var nodes: [AVAudioNode] = [playerNode]
        if let effect = effect {
            nodes.append(contentsOf: effect.units)
        }
        nodes.append(audioEngine.outputNode)
        
        for i in 0..<(nodes.count - 1) {
            audioEngine.connect(nodes[i], to: nodes[i + 1], format: nil)
        }
        
        audioEngine.stop()
        
        try audioEngine.enableManualRenderingMode(.offline, format: renderFormat, maximumFrameCount: renderBuffer.frameCapacity)
        try audioEngine.start()
        playerNode.play()
        
        var rate: Float = 1.0
        effect?.units.compactMap({ $0 as? AVAudioUnitTimePitch }).forEach({ rate *= $0.rate })
        
        let readSize = AVAudioFrameCount(Float(renderSize) * rate)
        guard let readBuffer = AVAudioPCMBuffer(pcmFormat: readAudioFile.processingFormat, frameCapacity: readSize) else {
            throw Error.cantCreateReadBuffer
        }
        
        while true {
            if readAudioFile.framePosition == readAudioFile.length {
                break
            }

            try readAudioFile.read(into: readBuffer)
            playerNode.scheduleBuffer(readBuffer, completionHandler: nil)

            let result = try audioEngine.renderOffline(renderBuffer.frameCapacity, to: renderBuffer)
            if result != .success {
                break
            }
            
            let expectedFrames = AVAudioFrameCount(Float(readBuffer.frameLength) / rate)
            if expectedFrames < renderBuffer.frameLength {
                renderBuffer.frameLength = expectedFrames
            }

            try writeAudioFile.write(from: renderBuffer)
        }
        
        playerNode.stop()
        audioEngine.stop()
    }
}
