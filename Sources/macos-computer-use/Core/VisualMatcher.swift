//
//  VisualMatcher.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import CoreGraphics
import AppKit
import Foundation

struct MatchResult: Codable {
    let found: Bool
    let x: Double
    let y: Double
    let width: Double
    let height: Double
    let confidence: Double
}

struct VisualMatcher {
    
    static func findImage(templatePath: String, threshold: Double = 0.8) -> MatchResult {
        // 1. 截取屏幕
        guard let screenImage = ScreenshotTool.capture().success ? CGDisplayCreateImage(CGMainDisplayID()) : nil else {
            return MatchResult(found: false, x: 0, y: 0, width: 0, height: 0, confidence: 0)
        }
        
        // 2. 加载模板
        guard let templateImage = NSImage(contentsOfFile: templatePath),
              let templateCGImage = templateImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return MatchResult(found: false, x: 0, y: 0, width: 0, height: 0, confidence: 0)
        }
        
        // 3. 使用简单的像素比较进行模板匹配
        return templateMatch(screen: screenImage, template: templateCGImage, threshold: threshold)
    }
    
    static func findImage(templatePath: String, in screenshotPath: String, threshold: Double = 0.8) -> MatchResult {
        guard let screenImage = NSImage(contentsOfFile: screenshotPath),
              let screenCGImage = screenImage.cgImage(forProposedRect: nil, context: nil, hints: nil),
              let templateImage = NSImage(contentsOfFile: templatePath),
              let templateCGImage = templateImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return MatchResult(found: false, x: 0, y: 0, width: 0, height: 0, confidence: 0)
        }
        
        return templateMatch(screen: screenCGImage, template: templateCGImage, threshold: threshold)
    }
    
    private static func templateMatch(screen: CGImage, template: CGImage, threshold: Double) -> MatchResult {
        let screenWidth = screen.width
        let screenHeight = screen.height
        let templateWidth = template.width
        let templateHeight = template.height
        
        guard templateWidth <= screenWidth, templateHeight <= screenHeight else {
            return MatchResult(found: false, x: 0, y: 0, width: 0, height: 0, confidence: 0)
        }
        
        // 简化实现：使用降采样进行快速匹配
        let scale = 4 // 降采样比例
        let smallScreen = downsample(image: screen, scale: scale)
        let smallTemplate = downsample(image: template, scale: scale)
        
        guard let sScreen = smallScreen, let sTemplate = smallTemplate else {
            return MatchResult(found: false, x: 0, y: 0, width: 0, height: 0, confidence: 0)
        }
        
        var bestMatch: (x: Int, y: Int, confidence: Double) = (0, 0, 0)
        
        let sWidth = sScreen.width
        let sHeight = sScreen.height
        let tWidth = sTemplate.width
        let tHeight = sTemplate.height
        
        guard let screenData = pixelData(from: sScreen),
              let templateData = pixelData(from: sTemplate) else {
            return MatchResult(found: false, x: 0, y: 0, width: 0, height: 0, confidence: 0)
        }
        
        // 滑动窗口搜索
        for y in stride(from: 0, to: sHeight - tHeight, by: 2) {
            for x in stride(from: 0, to: sWidth - tWidth, by: 2) {
                let confidence = calculateSimilarity(
                    screen: screenData,
                    template: templateData,
                    screenWidth: sWidth,
                    templateWidth: tWidth,
                    templateHeight: tHeight,
                    offsetX: x,
                    offsetY: y
                )
                
                if confidence > bestMatch.confidence {
                    bestMatch = (x, y, confidence)
                }
            }
        }
        
        if bestMatch.confidence >= threshold {
            return MatchResult(
                found: true,
                x: Double(bestMatch.x * scale),
                y: Double(bestMatch.y * scale),
                width: Double(templateWidth),
                height: Double(templateHeight),
                confidence: bestMatch.confidence
            )
        }
        
        return MatchResult(found: false, x: 0, y: 0, width: 0, height: 0, confidence: bestMatch.confidence)
    }
    
    private static func downsample(image: CGImage, scale: Int) -> CGImage? {
        let newWidth = image.width / scale
        let newHeight = image.height / scale
        
        guard let context = CGContext(
            data: nil,
            width: newWidth,
            height: newHeight,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        
        context.interpolationQuality = .medium
        context.draw(image, in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        return context.makeImage()
    }
    
    private static func pixelData(from image: CGImage) -> [UInt8]? {
        let width = image.width
        let height = image.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)
        
        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return pixels
    }
    
    private static func calculateSimilarity(
        screen: [UInt8],
        template: [UInt8],
        screenWidth: Int,
        templateWidth: Int,
        templateHeight: Int,
        offsetX: Int,
        offsetY: Int
    ) -> Double {
        var totalDiff: Double = 0
        var count = 0
        let bytesPerPixel = 4
        let screenBytesPerRow = bytesPerPixel * screenWidth
        let templateBytesPerRow = bytesPerPixel * templateWidth
        
        for y in 0..<templateHeight {
            for x in 0..<templateWidth {
                let screenIdx = (offsetY + y) * screenBytesPerRow + (offsetX + x) * bytesPerPixel
                let templateIdx = y * templateBytesPerRow + x * bytesPerPixel
                
                // 比较 RGB 通道（跳过 Alpha）
                for c in 0..<3 {
                    let diff = Double(screen[screenIdx + c]) - Double(template[templateIdx + c])
                    totalDiff += abs(diff)
                }
                count += 3
            }
        }
        
        let avgDiff = totalDiff / Double(count)
        let similarity = 1.0 - (avgDiff / 255.0)
        return similarity
    }
}
