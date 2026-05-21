//
//  DisplayListCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct DisplayListCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "display-list",
        abstract: "列出所有显示器"
    )
    
    @Flag(name: .long, help: "JSON 输出")
    var json: Bool = false
    
    func run() throws {
        let displays = SystemInfoManager.getDisplayList()
        
        if json {
            if let data = try? JSONEncoder().encode(displays),
               let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
            }
        } else {
            print("显示器列表:")
            for display in displays {
                let mainMarker = display.isMain ? " [主屏幕]" : ""
                print("  ID: \(display.id)\(mainMarker)")
                print("    尺寸: \(display.width) x \(display.height)")
                print("    位置: (\(Int(display.bounds.x)), \(Int(display.bounds.y)))")
            }
        }
    }
}
