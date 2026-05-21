//
//  WindowListCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct WindowListCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "window-list",
        abstract: "列出所有窗口"
    )

    @Flag(name: .shortAndLong, help: "只显示屏幕上的窗口")
    var onScreen = false

    @Option(name: .shortAndLong, help: "只显示指定 PID 的窗口")
    var pid: Int?

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        let options: WindowManager.WindowListOptions
        if let pid = pid {
            options = .ownedByApp(pid_t(pid))
        } else if onScreen {
            options = .onScreen
        } else {
            options = .all
        }

        let windows = WindowManager.listWindows(options: options)

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(windows)
            print(String(data: data, encoding: .utf8)!)
        } else {
            print("Windows (\(windows.count)):")
            for window in windows {
                let visible = window.isOnScreen ? "●" : "○"
                print("  \(visible) [\(window.id)] \(window.appName) - \(window.title)")
                print("      Bounds: (\(Int(window.bounds.x)), \(Int(window.bounds.y))) \(Int(window.bounds.width))x\(Int(window.bounds.height))")
            }
        }
    }
}
