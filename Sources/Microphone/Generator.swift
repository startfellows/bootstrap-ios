//
//  Created by Anton Spivak.
//  

import UIKit
import AVFoundation

public class Generator {
    
    public enum Error: Swift.Error {
        
        case unknown
    }
    
    public enum Format {
        
        case portrait
        case landscape
        
        fileprivate var size: CGSize {
            switch self {
            case .portrait: return CGSize(width: 1080, height: 1920)
            case .landscape: return CGSize(width: 1920, height: 1080)
            }
        }
        
        fileprivate var preset: String {
            switch self {
            case .portrait: return AVAssetExportPresetHighestQuality
            case .landscape: return AVAssetExportPreset1920x1080
            }
        }
    }
    
    public typealias Overlay = (_ duration: TimeInterval, _ size: CGSize) -> CALayer
    
    public init() {}
    
    public func mp4(format: Format, fromAudioFile audioFileURL: URL, overlay: Overlay?) throws -> URL {
        try createMovieWithSingleImageAndMusic(
            image: UIImage(color: .black, size: format.size)!,
            audioFileURL: audioFileURL,
            assetExportPresetQuality: format.preset,
            overlay: overlay
        )
    }
    
    private func createMovieWithSingleImageAndMusic(image: UIImage, audioFileURL: URL, assetExportPresetQuality: String, overlay: Overlay?) throws -> URL {
        let outputVideoFileURL = URL(fileURLWithPath: audioFileURL.deletingPathExtension().appendingPathExtension("mp4").absoluteString)
        let videoOnlyURL = outputVideoFileURL.appendingPathExtension("\(UUID().uuidString).mp4")
        
        try? FileManager.default.removeItem(at: videoOnlyURL)
        try? FileManager.default.removeItem(at: outputVideoFileURL)
        
        let audioAsset = AVURLAsset(url: URL(fileURLWithPath: audioFileURL.absoluteString))
        let length = TimeInterval(audioAsset.duration.seconds)
        
        try writeSingleImageToMovie(image: image, movieLength: length, outputFileURL: videoOnlyURL)
        
        let videoAsset = AVURLAsset(url: videoOnlyURL)
        try addAudioToMovie(audioAsset: audioAsset, inputVideoAsset: videoAsset, outputVideoFileURL: outputVideoFileURL, quality: assetExportPresetQuality, overlay: overlay)
    
        try? FileManager.default.removeItem(at: videoOnlyURL)
        
        return outputVideoFileURL
    }
    
    private func addAudioToMovie(audioAsset: AVURLAsset, inputVideoAsset: AVURLAsset, outputVideoFileURL: URL, quality: String, overlay: Overlay?) throws {
        let composition = AVMutableComposition()
        
        guard let videoAssetTrack = inputVideoAsset.tracks(withMediaType: .video).first,
              let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        else {
            throw Error.unknown
        }
        
        try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: inputVideoAsset.duration), of: videoAssetTrack, at: .zero)
        
        let audioStartTime: CMTime = .zero
        guard let audioAssetTrack = audioAsset.tracks(withMediaType: .audio).first,
              let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        else {
            throw Error.unknown
        }
        
        try compositionAudioTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: audioAsset.duration), of: audioAssetTrack, at: audioStartTime)
        
        guard let assetExport = AVAssetExportSession(asset: composition, presetName: quality) else { throw Error.unknown }
        assetExport.outputFileType = AVFileType.mp4
        assetExport.outputURL = outputVideoFileURL
        
        if let overlay = overlay {
            
            let videoSize = videoAssetTrack.naturalSize
            
            let videoLayer = CALayer()
            videoLayer.frame = CGRect(origin: .zero, size: videoSize)
            
            let overlayLayer = CALayer()
            overlayLayer.frame = CGRect(origin: .zero, size: videoSize)
            overlayLayer.addSublayer(overlay(composition.duration.seconds, videoSize))
            
            let outputLayer = CALayer()
            outputLayer.frame = CGRect(origin: .zero, size: videoSize)
            outputLayer.addSublayer(videoLayer)
            outputLayer.addSublayer(overlayLayer)
            
            let layer = CAShapeLayer()
            layer.frame = CGRect(origin: .zero, size: videoAssetTrack.naturalSize)
            
            let videoComposition = AVMutableVideoComposition()
            videoComposition.renderSize = videoSize
            videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
            videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: outputLayer)
            
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRange(start: .zero, duration: composition.duration)
            videoComposition.instructions = [instruction]
            
            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
            layerInstruction.setTransform(videoAssetTrack.preferredTransform, at: .zero)
            instruction.layerInstructions = [layerInstruction]
            
            assetExport.videoComposition = videoComposition
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        assetExport.exportAsynchronously(completionHandler: {
            semaphore.signal()
        })
        let _ = semaphore.wait(timeout: .distantFuture)
        
        if let error = assetExport.error {
            throw error
        }
    }
    
    private func writeSingleImageToMovie(image: UIImage, movieLength: TimeInterval, outputFileURL: URL) throws {
        let imageSize = image.size
        let videoWriter = try AVAssetWriter(outputURL: outputFileURL, fileType: AVFileType.mp4)
        
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: imageSize.width,
            AVVideoHeightKey: imageSize.height
        ]
        
        let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: nil)
        
        guard videoWriter.canAdd(videoWriterInput)
        else {
            throw Error.unknown
        }
        
        videoWriterInput.expectsMediaDataInRealTime = true
        videoWriter.add(videoWriterInput)
        
        videoWriter.startWriting()
        let timeScale: Int32 = 600 // recommended in CMTime for movies.
        let halfMovieLength = Float64(movieLength / 2) // videoWriter assumes frame lengths are equal.
        let startFrameTime = CMTimeMake(value: 0, timescale: timeScale)
        let endFrameTime = CMTimeMakeWithSeconds(halfMovieLength, preferredTimescale: timeScale)
        videoWriter.startSession(atSourceTime: startFrameTime)
        
        guard let cgImage = image.cgImage else { throw Error.unknown }
        let buffer: CVPixelBuffer = try self.pixelBuffer(fromImage: cgImage, size: imageSize)
        while !adaptor.assetWriterInput.isReadyForMoreMediaData { usleep(10) }
        adaptor.append(buffer, withPresentationTime: startFrameTime)
        while !adaptor.assetWriterInput.isReadyForMoreMediaData { usleep(10) }
        adaptor.append(buffer, withPresentationTime: endFrameTime)
        
        videoWriterInput.markAsFinished()
        
        let semaphore = DispatchSemaphore(value: 0)
        videoWriter.finishWriting(completionHandler: {
            semaphore.signal()
        })
        let _ = semaphore.wait(timeout: .distantFuture)
        
        if let error = videoWriter.error {
            throw error
        }
    }
    
    private func pixelBuffer(fromImage image: CGImage, size: CGSize) throws -> CVPixelBuffer {
        let options: CFDictionary = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ] as CFDictionary
        
        var pxbuffer: CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(size.width),
            Int(size.height),
            kCVPixelFormatType_32ARGB,
            options,
            &pxbuffer
        )
        
        guard let buffer = pxbuffer, status == kCVReturnSuccess
        else {
            throw Error.unknown
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        
        guard let pxdata = CVPixelBufferGetBaseAddress(buffer)
        else {
            throw Error.unknown
        }
        
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let context = CGContext(
                data: pxdata,
                width: Int(size.width),
                height: Int(size.height),
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: rgbColorSpace,
                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            throw Error.unknown
        }
        
        context.concatenate(CGAffineTransform(rotationAngle: 0))
        context.draw(image, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }
}

fileprivate extension UIImage {
    
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1.0)
        color.setFill()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage
        else {
            return nil
        }
        
        self.init(cgImage: cgImage)
    }
}
