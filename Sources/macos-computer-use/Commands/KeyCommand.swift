//
//  KeyCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser

struct KeyCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "key",
        abstract: "按键或组合键（如 command+c, shift+tab）"
    )

    @Option(name: .shortAndLong, help: "键名组合，用 + 连接（如 command+c）")
    var keys: String

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        let keyCodes = KeyboardController.parseKeys(keys)

        guard !keyCodes.isEmpty else {
            throw ValidationError("Invalid key combination: \(keys)")
        }

        KeyboardController.pressKeys(keyCodes)

        if json {
            print("""
            {
              "success": true,
              "action": "key",
              "keys": "\(keys)"
            }
            """)
        } else {
            print("✓ Key pressed: \(keys)")
        }
    }
}
