//
//  FocusedElementCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct FocusedElementCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "focused-element",
        abstract: "获取当前焦点 UI 元素信息"
    )

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() throws {
        guard let result = AccessibilityManager.getFocusedElement() else {
            if json {
                printJSON([
                    "success": false,
                    "error": "No focused element found"
                ])
            } else {
                print("✗ No focused element found")
            }
            throw ExitCode.failure
        }

        let info = result.info

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(info)
            print(String(data: data, encoding: .utf8)!)
        } else {
            print("Focused element:")
            print("  Role: \(info.role)")
            print("  Title: \(info.title)")
            if let value = info.value {
                print("  Value: \(value)")
            }
            if let id = info.identifier {
                print("  Identifier: \(id)")
            }
            if let desc = info.description {
                print("  Description: \(desc)")
            }
            print("  Bounds: (\(Int(info.bounds.x)), \(Int(info.bounds.y))) \(Int(info.bounds.width))x\(Int(info.bounds.height))")
            print("  Enabled: \(info.isEnabled)")
            print("  Focused: \(info.isFocused)")
        }
    }
}
