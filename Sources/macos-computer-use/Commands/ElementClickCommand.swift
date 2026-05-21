//
//  ElementClickCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser

struct ElementClickCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "element-click",
        abstract: "点击 UI 元素"
    )

    @Option(name: .long, help: "按角色查找")
    var role: String?

    @Option(name: .long, help: "按标题查找")
    var title: String?

    @Option(name: .long, help: "按标识符查找")
    var identifier: String?

    @Option(name: .long, help: "在指定应用中查找")
    var app: String?

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        let results = AccessibilityManager.findElements(
            byRole: role,
            byTitle: title,
            byIdentifier: identifier,
            inApp: app
        )

        guard let first = results.first else {
            if json {
                print("""
                {
                  "success": false,
                  "message": "Element not found"
                }
                """)
            } else {
                print("✗ Element not found")
            }
            return
        }

        let success = AccessibilityManager.clickElement(first.element)
        let info = first.info

        if json {
            print("""
            {
              "success": \(success),
              "element": {
                "role": "\(info.role)",
                "title": "\(info.title)",
                "bounds": {
                  "x": \(info.bounds.x),
                  "y": \(info.bounds.y),
                  "width": \(info.bounds.width),
                  "height": \(info.bounds.height)
                }
              }
            }
            """)
        } else {
            if success {
                print("✓ Clicked \(info.role): \(info.title)")
            } else {
                print("✗ Failed to click \(info.role): \(info.title)")
            }
        }
    }
}
