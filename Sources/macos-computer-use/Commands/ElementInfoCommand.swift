//
//  ElementInfoCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct ElementInfoCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "element-info",
        abstract: "获取指定位置的 UI 元素信息"
    )

    @Option(name: .short, help: "X 坐标")
    var x: Int

    @Option(name: .short, help: "Y 坐标")
    var y: Int

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        guard let result = AccessibilityManager.getElementAtPosition(
            x: CGFloat(x),
            y: CGFloat(y)
        ) else {
            if json {
                print("""
                {
                  "success": false,
                  "message": "No element found at (\(x), \(y))"
                }
                """)
            } else {
                print("✗ No element found at (\(x), \(y))")
            }
            return
        }

        let info = result.info

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(info)
            print(String(data: data, encoding: .utf8)!)
        } else {
            print("Element at (\(x), \(y)):")
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
