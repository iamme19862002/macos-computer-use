//
//  OCRManager.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Vision
import AppKit

struct OCRResult: Codable {
    let text: String
    let confidence: Float
    let boundingBox: OCRBox
}

struct OCRBox: Codable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double
}

struct OCRManager {
    
    static func recognizeText(in imagePath: String) -> [OCRResult] {
        guard let image = NSImage(contentsOfFile: imagePath),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return []
        }
        
        return recognizeText(in: cgImage)
    }
    
    static func recognizeText(in cgImage: CGImage) -> [OCRResult] {
        var results: [OCRResult] = []
        let semaphore = DispatchSemaphore(value: 0)
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                semaphore.signal()
                return
            }
            
            for observation in observations {
                guard let candidate = observation.topCandidates(1).first else { continue }
                
                let box = observation.boundingBox
                let result = OCRResult(
                    text: candidate.string,
                    confidence: candidate.confidence,
                    boundingBox: OCRBox(
                        x: Double(box.origin.x * CGFloat(cgImage.width)),
                        y: Double((1 - box.origin.y - box.height) * CGFloat(cgImage.height)),
                        width: Double(box.width * CGFloat(cgImage.width)),
                        height: Double(box.height * CGFloat(cgImage.height))
                    )
                )
                results.append(result)
            }
            semaphore.signal()
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["zh-Hans", "en-US"]
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            semaphore.signal()
        }
        
        semaphore.wait()
        return results
    }
    
    static func recognizeTextAtRegion(imagePath: String, region: String) -> [OCRResult] {
        let parts = region.split(separator: ",").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        guard parts.count == 4 else { return [] }
        
        guard let image = NSImage(contentsOfFile: imagePath),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return []
        }
        
        let rect = CGRect(x: parts[0], y: parts[1], width: parts[2], height: parts[3])
        guard let cropped = cgImage.cropping(to: rect) else { return [] }
        
        return recognizeText(in: cropped)
    }
}
