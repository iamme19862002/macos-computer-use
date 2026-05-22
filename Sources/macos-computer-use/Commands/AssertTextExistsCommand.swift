//
//  AssertTextExistsCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation
import Vision
import AppKit

struct AssertTextExistsCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "assert-text-exists",
        abstract: "断言屏幕上的文本存在（使用 OCR）"
    )
    
    @Option(name: .shortAndLong, help: "要查找的文本")
    var text: String
    
    @Option(name: .long, help: "目标应用名称（可选，不指定则全屏查找）")
    var app: String?
    
    @Option(name: .long, help: "指定查找区域 (x,y,width,height)")
    var region: String?
    
    @Option(name: .long, help: "超时时间（秒）", transform: { Double($0) ?? 5 })
    var timeout: Double = 5
    
    @Option(name: .long, help: "轮询间隔（秒）", transform: { Double($0) ?? 0.5 })
    var interval: Double = 0.5
    
    @Flag(name: .long, help: "反向断言：断言文本不存在")
    var notExists: Bool = false
    
    @Flag(name: .long, help: "JSON 输出")
    var json: Bool = false
    
    func run() throws {
        let startTime = Date()
        var found = false
        var foundResult: OCRResult? = nil
        
        while Date().timeIntervalSince(startTime) < timeout {
            if let result = findTextOnScreen(text: text, app: app, region: region) {
                found = true
                foundResult = result
                break
            }
            
            if notExists {
                break
            }
            
            Thread.sleep(forTimeInterval: interval)
        }
        
        let waited = Date().timeIntervalSince(startTime)
        let success = notExists ? !found : found
        
        if json {
            var output: [String: Any] = [
                "success": success,
                "assertion": notExists ? "text-not-exists" : "text-exists",
                "text": text,
                "found": found,
                "waited": waited,
                "timeout": timeout
            ]
            if let result = foundResult {
                output["location"] = [
                    "x": result.boundingBox.x,
                    "y": result.boundingBox.y,
                    "width": result.boundingBox.width,
                    "height": result.boundingBox.height
                ]
                output["confidence"] = result.confidence
            }
            printJSON(output)
        } else {
            if success {
                if notExists {
                    print("✅ 断言通过：文本「\(text)」不存在（等待了 \(String(format: "%.2f", waited)) 秒）")
                } else {
                    print("✅ 断言通过：文本「\(text)」存在（等待了 \(String(format: "%.2f", waited)) 秒）")
                    if let result = foundResult {
                        print("   位置: (\(Int(result.boundingBox.x)), \(Int(result.boundingBox.y)))")
                        print("   置信度: \(String(format: "%.2f", result.confidence * 100))%")
                    }
                }
            } else {
                if notExists {
                    print("❌ 断言失败：文本「\(text)」仍然存在")
                } else {
                    print("❌ 断言失败：文本「\(text)」未找到（超时 \(timeout) 秒）")
                }
                throw ExitCode.failure
            }
        }
        
        if !success {
            throw ExitCode.failure
        }
    }
    
    private func findTextOnScreen(text: String, app: String?, region: String?) -> OCRResult? {
        let screenshotPath = "/tmp/assert_ocr_screenshot_\(UUID().uuidString).png"
        
        let result = ScreenshotTool.capture(outputDir: "/tmp", filename: "assert_ocr_\(UUID().uuidString).png")
        
        defer {
            try? FileManager.default.removeItem(atPath: result.filepath)
        }
        
        guard result.success else { return nil }
        
        let results: [OCRResult]
        if let regionStr = region {
            results = OCRManager.recognizeTextAtRegion(imagePath: result.filepath, region: regionStr)
        } else {
            results = OCRManager.recognizeText(in: result.filepath)
        }
        
        let lowercasedText = text.lowercased()
        for result in results {
            if result.text.lowercased().contains(lowercasedText) {
                return result
            }
        }
        
        return nil
    }
}
