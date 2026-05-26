//
//  ElementListCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct ElementListCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "element-list",
        abstract: "列出应用的 UI 元素树，自动包含主窗口和系统对话框（Sheet/Panel）"
    )

    @Option(name: .long, help: "指定应用名称（会自动激活应用）")
    var app: String?

    @Option(name: .long, help: "最大深度 (默认: 10，SwiftUI 应用需要更大深度)")
    var depth: Int?

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

        let maxDepth = depth ?? 10
        let tree = AccessibilityManager.getElementTree(inApp: app, maxDepth: maxDepth)

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(tree)
            print(String(data: data, encoding: .utf8)!)
        } else {
            print("UI Element Tree (depth: \(maxDepth)):")
            for (index, root) in tree.enumerated() {
                printElement(root, prefix: "  [\(index)]", depth: 0, maxDepth: maxDepth)
            }
        }
    }

    private func printElement(_ element: UIElementInfo, prefix: String, depth: Int, maxDepth: Int) {
        guard depth < maxDepth else { return }

        let indent = String(repeating: "  ", count: depth)
        print("\(indent)\(prefix) \(element.role): \(element.title)")
        if let id = element.identifier {
            print("\(indent)      ID: \(id)")
        }
        print("\(indent)      Bounds: (\(Int(element.bounds.x)), \(Int(element.bounds.y))) \(Int(element.bounds.width))x\(Int(element.bounds.height))")

        if let children = element.children {
            for (i, child) in children.enumerated() {
                printElement(child, prefix: "[\(i)]", depth: depth + 1, maxDepth: maxDepth)
            }
        }
    }
}
