//
//  FindImageCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct FindImageCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "find-image",
        abstract: "在屏幕上查找图片"
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
        
        if json {
            if let data = try? JSONEncoder().encode(result),
               let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
            }
        } else {
            if result.found {
                print("✅ 找到图片")
                print("   位置: (\(Int(result.x)), \(Int(result.y)))")
                print("   尺寸: \(Int(result.width)) x \(Int(result.height))")
                print("   置信度: \(String(format: "%.2f", result.confidence))")
            } else {
                print("❌ 未找到图片 (最佳匹配置信度: \(String(format: "%.2f", result.confidence)))")
                throw ExitCode.failure
            }
        }
    }
}
