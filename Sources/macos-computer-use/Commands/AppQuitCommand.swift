//
//  AppQuitCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser

struct AppQuitCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "app-quit",
        abstract: "关闭应用程序"
    )

    @Argument(help: "应用名称或 Bundle ID")
    var appName: String

    @Flag(name: .shortAndLong, help: "强制退出")
    var force = false

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        let result = AppManager.quit(appName: appName, force: force)

        if json {
            print("""
            {
              "success": \(result.success),
              "message": "\(result.message)"
            }
            """)
        } else {
            print(result.success ? "✓ \(result.message)" : "✗ \(result.message)")
        }
    }
}
