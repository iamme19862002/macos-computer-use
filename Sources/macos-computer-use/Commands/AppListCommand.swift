//
//  AppListCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct AppListCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "app-list",
        abstract: "列出所有正在运行的应用程序"
    )

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        let apps = AppManager.listRunningApps()

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(apps)
            print(String(data: data, encoding: .utf8)!)
        } else {
            print("Running applications (\(apps.count)):")
            for app in apps {
                let status = app.isActive ? "●" : (app.isHidden ? "◌" : "○")
                print("  \(status) \(app.name) (PID: \(app.pid))")
            }
        }
    }
}
