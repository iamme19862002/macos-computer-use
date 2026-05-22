//
//  KeySequenceCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct KeySequenceCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "key-sequence",
        abstract: "发送按键序列（如 Vim 操作 esc,gg,dG）"
    )
    
    @Option(name: .shortAndLong, help: "按键序列，用逗号分隔（如 esc,gg,dG）")
    var keys: String
    
    @Option(name: .shortAndLong, help: "按键间隔（毫秒）", transform: { UInt32($0) ?? 100 })
    var delay: UInt32 = 100
    
    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false
    
    func run() throws {
        let keyItems = keys.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        guard !keyItems.isEmpty else {
            throw ValidationError("Invalid key sequence: \(keys)")
        }
        
        var pressedKeys: [String] = []
        
        for item in keyItems {
            let keyCodes = KeyboardController.parseKeys(item)
            guard !keyCodes.isEmpty else {
                throw ValidationError("Invalid key in sequence: \(item)")
            }
            
            KeyboardController.pressKeys(keyCodes)
            pressedKeys.append(item)
            
            if delay > 0 {
                usleep(delay * 1000) // 毫秒转微秒
            }
        }
        
        if json {
            print("""
            {
              "success": true,
              "action": "key-sequence",
              "keys": "\(keys)",
              "delay": \(delay),
              "pressed": \(pressedKeys.count)
            }
            """)
        } else {
            print("✓ Key sequence pressed: \(keys) (delay: \(delay)ms)")
        }
    }
}
