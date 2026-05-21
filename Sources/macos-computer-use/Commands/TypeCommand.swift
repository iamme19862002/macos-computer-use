//
//  TypeCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser

struct TypeCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "type",
        abstract: "输入文本字符串"
    )

    @Option(name: .shortAndLong, help: "要输入的文本")
    var text: String

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        KeyboardController.typeText(text)

        if json {
            print("""
            {
              "success": true,
              "action": "type",
              "text": "\(text)"
            }
            """)
        } else {
            print("✓ Typed: \(text)")
        }
    }
}
