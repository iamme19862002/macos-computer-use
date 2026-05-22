//
//  MenuClickCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct MenuClickCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "menu-click",
        abstract: "通过系统菜单栏操作"
    )

    @Argument(help: "菜单路径，如 '文件,打开' 或 'Edit,Copy'")
    var path: String

    @Option(name: .long, help: "目标应用名称（默认前台应用）")
    var app: String?

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() throws {
        let menuItems = path.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        guard menuItems.count >= 2 else {
            if json {
                printJSON(["success": false, "error": "菜单路径需要至少两个层级，如 '文件,打开'"])
            } else {
                print("✗ 菜单路径需要至少两个层级，如 '文件,打开'")
            }
            throw ExitCode.failure
        }

        let targetApp = app ?? ""

        var script: String
        if targetApp.isEmpty {
            script = """
            tell application "System Events"
                set frontApp to first application process whose frontmost is true
                tell frontApp
            """
        } else {
            script = """
            tell application "System Events"
                tell application process "\(targetApp)"
            """
        }

        for (index, item) in menuItems.enumerated() {
            if index == 0 {
                script += "\n                click menu item \"\(item)\" of menu bar 1"
            } else if index == 1 {
                script += "\n                click menu item \"\(item)\" of menu 1 of menu item \"\(menuItems[0])\" of menu bar 1"
            } else {
                script += "\n                click menu item \"\(item)\" of menu 1 of menu item \"\(menuItems[index - 1])\" of menu 1 of menu item \"\(menuItems[0])\" of menu bar 1"
            }
        }

        script += "\n                end tell\n            end tell"

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            let success = process.terminationStatus == 0

            if json {
                printJSON([
                    "success": success,
                    "path": menuItems,
                    "app": targetApp,
                    "output": output.trimmingCharacters(in: .whitespacesAndNewlines)
                ])
            } else {
                if success {
                    print("✓ Menu clicked: \(menuItems.joined(separator: " > "))")
                } else {
                    print("✗ Failed to click menu: \(output)")
                }
            }

            if !success {
                throw ExitCode.failure
            }
        } catch {
            if json {
                printJSON(["success": false, "error": error.localizedDescription])
            } else {
                print("✗ Failed to click menu: \(error.localizedDescription)")
            }
            throw ExitCode.failure
        }
    }
}
