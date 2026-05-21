//
//  DoubleClickCommand.swift
//  macos-computer-use
//
//  Created by iamme19862002 on 2025.
//  Copyright (c) 2025 iamme19862002. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import CoreGraphics

struct DoubleClickCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "double-click",
        abstract: "双击（可选坐标）"
    )

    @Option(name: .short, help: "X 坐标（可选）")
    var x: Int?

    @Option(name: .short, help: "Y 坐标（可选）")
    var y: Int?

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        let point: CGPoint? = (x != nil && y != nil) ? CGPoint(x: x!, y: y!) : nil
        MouseController.doubleClick(at: point)

        if json {
            if let px = x, let py = y {
                print("""
                {
                  "success": true,
                  "action": "double_click",
                  "coordinate": [\(px), \(py)]
                }
                """)
            } else {
                print("""
                {
                  "success": true,
                  "action": "double_click"
                }
                """)
            }
        } else {
            if let px = x, let py = y {
                print("✓ Double clicked at (\(px), \(py))")
            } else {
                print("✓ Double clicked at current position")
            }
        }
    }
}
