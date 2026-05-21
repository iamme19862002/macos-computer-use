//
//  ClickImageCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct ClickImageCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "click-image",
        abstract: "查找并点击图片"
    )
    
    @Argument(help: "模板图片路径")
    var templatePath: String
    
    @Option(name: .long, help: "匹配阈值 (0.0-1.0)", transform: { Double($0) ?? 0.8 })
    var threshold: Double = 0.8
    
    @Flag(name: .long, help: "JSON 输出")
    var json: Bool = false
    
    func run() throws {
        print("🔍 正在查找图片...")
        let result = VisualMatcher.findImage(templatePath: templatePath, threshold: threshold)
        
        if result.found {
            let centerX = result.x + result.width / 2
            let centerY = result.y + result.height / 2
            
            MouseController.moveTo(x: Int(centerX), y: Int(centerY))
            MouseController.leftClick()
            
            if json {
                printJSON([
                    "found": true,
                    "x": centerX,
                    "y": centerY,
                    "confidence": result.confidence
                ])
            } else {
                print("✅ 已点击图片中心 (\(Int(centerX)), \(Int(centerY)))")
            }
        } else {
            if json {
                printJSON([
                    "found": false,
                    "confidence": result.confidence
                ])
            } else {
                print("❌ 未找到图片 (最佳匹配置信度: \(String(format: "%.2f", result.confidence)))")
                throw ExitCode.failure
            }
        }
    }
}
