//
//  OsascriptCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct OsascriptCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "osascript",
        abstract: "执行 AppleScript 或 JavaScript for Automation (JXA) 脚本"
    )

    @Argument(help: "要执行的脚本内容")
    var script: String

    @Option(name: .long, help: "脚本语言（applescript 或 javascript，默认 applescript）")
    var language: String = "applescript"

    @Option(name: .long, help: "从文件读取脚本")
    var file: String?

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")

        let langFlag = language.lowercased() == "javascript" ? "-l" : nil
        let langValue = language.lowercased() == "javascript" ? "JavaScript" : nil

        var arguments: [String] = []
        if let flag = langFlag, let value = langValue {
            arguments.append(flag)
            arguments.append(value)
        }

        if let filePath = file {
            let expandedPath = NSString(string: filePath).expandingTildeInPath
            arguments.append(expandedPath)
        } else {
            arguments.append("-e")
            arguments.append(script)
        }

        process.arguments = arguments

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
                    "language": language,
                    "output": output.trimmingCharacters(in: .whitespacesAndNewlines),
                    "exitCode": process.terminationStatus
                ])
            } else {
                if success {
                    print(output.trimmingCharacters(in: .whitespacesAndNewlines))
                } else {
                    print("✗ Script failed: \(output)")
                }
            }

            if !success {
                throw ExitCode.failure
            }
        } catch {
            if json {
                printJSON([
                    "success": false,
                    "error": error.localizedDescription
                ])
            } else {
                print("✗ Failed to execute script: \(error.localizedDescription)")
            }
            throw ExitCode.failure
        }
    }
}
