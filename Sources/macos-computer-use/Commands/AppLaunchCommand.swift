//
//  AppLaunchCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser

struct AppLaunchCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "app-launch",
        abstract: "启动应用程序"
    )

    @Argument(help: "应用名称或 Bundle ID")
    var appName: String

    @Flag(name: .shortAndLong, help: "等待应用启动完成")
    var wait = false

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        let result = AppManager.launch(appName: appName, wait: wait)

        if json {
            print("""
            {
              "success": \(result.success),
              "message": "\(result.message)",
              "pid": \(result.pid.map(String.init) ?? "null")
            }
            """)
        } else {
            print(result.success ? "✓ \(result.message)" : "✗ \(result.message)")
        }
    }
}
