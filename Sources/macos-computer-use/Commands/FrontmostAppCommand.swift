//
//  FrontmostAppCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct FrontmostAppCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "frontmost-app",
        abstract: "获取当前前台应用信息"
    )

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() throws {
        guard let app = AppManager.getFrontmostApp() else {
            if json {
                printJSON([
                    "success": false,
                    "error": "No frontmost application found"
                ])
            } else {
                print("✗ No frontmost application found")
            }
            throw ExitCode.failure
        }

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(app)
            print(String(data: data, encoding: .utf8)!)
        } else {
            print("Frontmost application:")
            print("  Name: \(app.name)")
            if let bundleId = app.bundleIdentifier {
                print("  Bundle ID: \(bundleId)")
            }
            print("  PID: \(app.pid)")
            print("  Hidden: \(app.isHidden ? "Yes" : "No")")
        }
    }
}
