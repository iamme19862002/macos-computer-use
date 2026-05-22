//
//  MouseHoverCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct MouseHoverCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "mouse-hover",
        abstract: "鼠标悬停在指定位置或元素上"
    )
    
    @Option(name: .long, help: "目标应用名称")
    var app: String?
    
    @Option(name: .long, help: "目标元素名称")
    var target: String?
    
    @Option(name: .long, help: "X 坐标")
    var x: Double?
    
    @Option(name: .long, help: "Y 坐标")
    var y: Double?
    
    @Option(name: .long, help: "悬停持续时间（秒）", transform: { Double($0) ?? 1.0 })
    var duration: Double = 1.0
    
    @Flag(name: .long, help: "JSON 输出")
    var json: Bool = false
    
    func run() throws {
        var finalX: Double
        var finalY: Double
        
        if let targetName = target {
            let results = AccessibilityManager.findElements(byTitle: targetName, inApp: app)
            guard let element = results.first?.info else {
                throw ValidationError("Target '\(targetName)' not found")
            }
            finalX = element.bounds.x + element.bounds.width / 2
            finalY = element.bounds.y + element.bounds.height / 2
        } else if let xVal = x, let yVal = y {
            finalX = xVal
            finalY = yVal
        } else {
            throw ValidationError("请指定 --target 或 --x/--y")
        }
        
        MouseController.moveTo(x: Int(finalX), y: Int(finalY))
        Thread.sleep(forTimeInterval: duration)
        
        if json {
            printJSON([
                "success": true,
                "action": "hover",
                "x": finalX,
                "y": finalY,
                "duration": duration
            ])
        } else {
            print("✅ 鼠标悬停在 (\(Int(finalX)), \(Int(finalY)))，持续 \(duration) 秒")
        }
    }
}
