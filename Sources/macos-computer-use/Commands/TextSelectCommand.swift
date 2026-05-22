//
//  TextSelectCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct TextSelectCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "text-select",
        abstract: "选中文本或获取已选文本"
    )

    @Option(name: .long, help: "要选择的文本内容（不指定则获取当前选中文本）")
    var text: String?

    @Flag(name: .long, help: "全选模式（command+a）")
    var all = false

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() throws {
        if all {
            KeyboardController.pressKeys(KeyboardController.parseKeys("command+a"))
            if json {
                printJSON(["success": true, "action": "select-all"])
            } else {
                print("✓ Select all executed")
            }
            return
        }

        if let targetText = text {
            let script = """
            tell application "System Events"
                keystroke "f" using command down
                delay 0.1
                keystroke "\(targetText)"
                delay 0.1
                key code 53
                delay 0.1
                keystroke "\(targetText)" using {command down, shift down}
            end tell
            """

            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
            process.arguments = ["-e", script]

            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe

            do {
                try process.run()
                process.waitUntilExit()

                let success = process.terminationStatus == 0

                if json {
                    printJSON([
                        "success": success,
                        "action": "select-text",
                        "text": targetText
                    ])
                } else {
                    if success {
                        print("✓ Text selected: \(targetText)")
                    } else {
                        print("✗ Failed to select text")
                    }
                }

                if !success {
                    throw ExitCode.failure
                }
            } catch {
                if json {
                    printJSON(["success": false, "error": error.localizedDescription])
                } else {
                    print("✗ Failed to select text: \(error.localizedDescription)")
                }
                throw ExitCode.failure
            }
        } else {
            let script = """
            tell application "System Events"
                return (the clipboard as text)
            end tell
            """

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
                        "selectedText": output.trimmingCharacters(in: .whitespacesAndNewlines)
                    ])
                } else {
                    if success {
                        print(output.trimmingCharacters(in: .whitespacesAndNewlines))
                    } else {
                        print("✗ Failed to get selected text")
                    }
                }

                if !success {
                    throw ExitCode.failure
                }
            } catch {
                if json {
                    printJSON(["success": false, "error": error.localizedDescription])
                } else {
                    print("✗ Failed to get selected text: \(error.localizedDescription)")
                }
                throw ExitCode.failure
            }
        }
    }
}
