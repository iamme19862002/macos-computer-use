//
//  ElementFindCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct ElementFindCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "element-find",
        abstract: "查找 UI 元素，自动聚焦应用"
    )

    @Option(name: .long, help: "按角色查找 (如: button, textfield)")
    var role: String?

    @Option(name: .long, help: "按标题查找")
    var title: String?

    @Option(name: .long, help: "按标识符查找")
    var identifier: String?

    @Option(name: .long, help: "按描述查找")
    var description: String?

    @Option(name: .long, help: "在指定应用中查找（会自动激活应用）")
    var app: String?

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        // 如果指定了应用，先激活应用
        if let appName = app {
            let activateResult = AppManager.activate(appName: appName)
            if !activateResult.success {
                if json {
                    print("""
                    {
                      "success": false,
                      "message": "Failed to activate app: \(appName)"
                    }
                    """)
                } else {
                    print("✗ Failed to activate app: \(appName)")
                }
                return
            }
            // 等待应用完全激活
            try await Task.sleep(nanoseconds: 300_000_000)
        }

        let results = AccessibilityManager.findElements(
            byRole: role,
            byTitle: title,
            byIdentifier: identifier,
            byDescription: description,
            inApp: app
        )

        if json {
            let infos = results.map { $0.info }
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(infos)
            print(String(data: data, encoding: .utf8)!)
        } else {
            print("Found \(results.count) element(s):")
            for (index, result) in results.enumerated() {
                let info = result.info
                print("  [\(index)] \(info.role): \(info.title)")
                if let id = info.identifier {
                    print("      ID: \(id)")
                }
                print("      Bounds: (\(Int(info.bounds.x)), \(Int(info.bounds.y))) \(Int(info.bounds.width))x\(Int(info.bounds.height))")
                print("      Enabled: \(info.isEnabled), Focused: \(info.isFocused)")
            }
        }
    }
}
