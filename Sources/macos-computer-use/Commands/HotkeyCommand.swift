//
//  HotkeyCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct HotkeyCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "hotkey",
        abstract: "发送组合快捷键（如 command+s, shift+tab）"
    )
    
    @Option(name: .shortAndLong, help: "键名组合，用 + 连接（如 command+c, shift+tab）")
    var keys: String
    
    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false
    
    func run() throws {
        let keyCodes = KeyboardController.parseKeys(keys)
        
        guard !keyCodes.isEmpty else {
            throw ValidationError("Invalid key combination: \(keys)")
        }
        
        KeyboardController.pressKeys(keyCodes)
        
        if json {
            print("""
            {
              "success": true,
              "action": "hotkey",
              "keys": "\(keys)"
            }
            """)
        } else {
            print("✓ Hotkey pressed: \(keys)")
        }
    }
}
