//
//  ScreenInfoCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct ScreenInfoCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "screen-info",
        abstract: "获取主屏幕信息"
    )
    
    @Flag(name: .long, help: "JSON 输出")
    var json: Bool = false
    
    func run() throws {
        let info = SystemInfoManager.getScreenInfo()
        
        if json {
            printJSON([
                "x": info.x,
                "y": info.y,
                "width": info.width,
                "height": info.height
            ])
        } else {
            print("主屏幕信息:")
            print("  位置: (\(Int(info.x)), \(Int(info.y)))")
            print("  尺寸: \(Int(info.width)) x \(Int(info.height))")
        }
    }
}
