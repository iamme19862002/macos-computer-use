//
//  OCRCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct OCRCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "ocr",
        abstract: "识别图片中的文字"
    )
    
    @Argument(help: "图片路径")
    var imagePath: String
    
    @Option(name: .long, help: "指定区域 (格式: x,y,width,height)")
    var region: String?
    
    @Flag(name: .long, help: "JSON 输出")
    var json: Bool = false
    
    func run() throws {
        let results: [OCRResult]
        if let region = region {
            results = OCRManager.recognizeTextAtRegion(imagePath: imagePath, region: region)
        } else {
            results = OCRManager.recognizeText(in: imagePath)
        }
        
        if json {
            if let data = try? JSONEncoder().encode(results),
               let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
            }
        } else {
            print("识别结果 (共 \(results.count) 个):")
            for (index, result) in results.enumerated() {
                print("\(index + 1). \(result.text)")
                print("   置信度: \(String(format: "%.2f", result.confidence))")
                print("   位置: (\(Int(result.boundingBox.x)), \(Int(result.boundingBox.y))) \(Int(result.boundingBox.width))x\(Int(result.boundingBox.height))")
            }
        }
    }
}
