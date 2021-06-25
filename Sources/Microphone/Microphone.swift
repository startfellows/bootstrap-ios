//
//  Created by Anton Spivak.
//  

import Foundation
import AVFoundation
import Accelerate
import CoreAudio
import Speech

public class Recorder {
    
    public struct Response {
        
        public let fileURL: URL
        public let text: String?
        public let meterings: [Metering]
        public let duration: TimeInterval
    }
    
    public private(set) var session: Session? = nil
    public init() {}
    
    public func record(_ format: Format) throws {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let fileURL = documentsURL[0].appendingPathComponent("\(UUID().uuidString).caf")
        
        if fileManager.fileExists(atPath: fileURL.relativePath) {
            try FileManager.default.removeItem(at: fileURL)
        }
        
        let engine = AVAudioEngine()
        let inputNode = engine.inputNode
        let inputFormat = inputNode.inputFormat(forBus: 0)
        
        inputNode.installTap(
            onBus: 0,
            bufferSize: 4096,
            format: inputFormat,
            block: { [weak self] (buffer: AVAudioPCMBuffer, time: AVAudioTime) in
                self?.session?.accept(buffer, with: time)
            }
        )
        
        session = try Session(engine: engine, fileURL: fileURL, format: inputFormat, type: format)
        session?.engine.prepare()
        try session?.engine.start()
    }
    
    @discardableResult
    public func stop() throws -> Response {
        guard let session = session
        else {
            throw Error.sessionDoesntExist
        }
        
        let inputNode = session.engine.inputNode
        inputNode.removeTap(onBus: 0)

        session.stop()
        self.session = nil
        
        let fileManager = FileManager.default

        let temporaryURL = session.file.url
        let outputURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("record.\(session.format.rawValue)")
        let asset = AVURLAsset(url: temporaryURL)
        
        if fileManager.fileExists(atPath: outputURL.relativePath) {
            try FileManager.default.removeItem(at: outputURL)
        }
        
        switch session.format {
        case .caf:
            try fileManager.moveItem(at: temporaryURL, to: outputURL)
        case .m4a:
            let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)
            exporter?.outputFileType = .m4a
            exporter?.outputURL = outputURL
            
            let s = DispatchSemaphore(value: 0)
            exporter?.exportAsynchronously(completionHandler: {
                s.signal()
            })
            
            let _ = s.wait(timeout: .distantFuture)
            
            if let error = exporter?.error {
                throw error
            }
        }
        
        if fileManager.fileExists(atPath: temporaryURL.relativePath) {
            try FileManager.default.removeItem(at: temporaryURL)
        }
        
        return Response(fileURL: outputURL, text: session.text, meterings: session.meterings, duration: asset.duration.seconds)
    }
}
