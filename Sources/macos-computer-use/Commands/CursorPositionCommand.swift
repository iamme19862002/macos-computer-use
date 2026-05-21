//
//  CursorPositionCommand.swift
//  macos-computer-use
//
//  Created by iamme19862002 on 2025.
//  Copyright (c) 2025 iamme19862002. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser

struct CursorPositionCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "cursor-position",
        abstract: "获取当前光标位置"
    )

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        let pos = MouseController.currentPosition()

        if json {
            print("""
            {
              "x": \(Int(pos.x)),
              "y": \(Int(pos.y))
            }
            """)
        } else {
            print("Cursor position: (\(Int(pos.x)), \(Int(pos.y)))")
        }
    }
}
