//
//  BrowserNavigateCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct BrowserNavigateCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "browser-navigate",
        abstract: "在浏览器中导航到指定 URL"
    )

    @Argument(help: "目标 URL")
    var url: String

    @Option(name: .long, help: "浏览器名称（默认 Safari）")
    var browser: String = "Safari"

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() throws {
        let script = """
        tell application "\(browser)"
            activate
            set URL of front document to "\(url)"
        end tell
        """

        let result = runAppleScript(script)

        if json {
            printJSON([
                "success": result.success,
                "url": url,
                "browser": browser,
                "output": result.output
            ])
        } else {
            if result.success {
                print("✓ Navigated \(browser) to \(url)")
            } else {
                print("✗ Failed to navigate: \(result.output)")
            }
        }

        if !result.success {
            throw ExitCode.failure
        }
    }
}

struct BrowserGetUrlCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "browser-get-url",
        abstract: "获取浏览器当前页面 URL"
    )

    @Option(name: .long, help: "浏览器名称（默认 Safari）")
    var browser: String = "Safari"

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() throws {
        let script = """
        tell application "\(browser)"
            return URL of front document
        end tell
        """

        let result = runAppleScript(script)

        if json {
            printJSON([
                "success": result.success,
                "url": result.output.trimmingCharacters(in: .whitespacesAndNewlines),
                "browser": browser
            ])
        } else {
            if result.success {
                print(result.output.trimmingCharacters(in: .whitespacesAndNewlines))
            } else {
                print("✗ Failed to get URL: \(result.output)")
            }
        }

        if !result.success {
            throw ExitCode.failure
        }
    }
}

struct BrowserExecJsCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "browser-exec-js",
        abstract: "在浏览器当前页面执行 JavaScript"
    )

    @Argument(help: "要执行的 JavaScript 代码")
    var script: String

    @Option(name: .long, help: "浏览器名称（默认 Safari）")
    var browser: String = "Safari"

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() throws {
        let escapedScript = script.replacingOccurrences(of: "\"", with: "\\\"")

        let appleScript = """
        tell application "\(browser)"
            tell front document
                do JavaScript "\(escapedScript)"
            end tell
        end tell
        """

        let result = runAppleScript(appleScript)

        if json {
            printJSON([
                "success": result.success,
                "result": result.output.trimmingCharacters(in: .whitespacesAndNewlines),
                "browser": browser
            ])
        } else {
            if result.success {
                print(result.output.trimmingCharacters(in: .whitespacesAndNewlines))
            } else {
                print("✗ Failed to execute JavaScript: \(result.output)")
            }
        }

        if !result.success {
            throw ExitCode.failure
        }
    }
}

struct BrowserNewTabCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "browser-new-tab",
        abstract: "在浏览器中新建标签页"
    )

    @Argument(help: "可选的 URL")
    var url: String?

    @Option(name: .long, help: "浏览器名称（默认 Safari）")
    var browser: String = "Safari"

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() throws {
        let script: String
        if let url = url {
            script = """
            tell application "\(browser)"
                activate
                open location "\(url)"
            end tell
            """
        } else {
            script = """
            tell application "\(browser)"
                activate
                tell application "System Events" to keystroke "t" using command down
            end tell
            """
        }

        let result = runAppleScript(script)

        if json {
            printJSON([
                "success": result.success,
                "url": url ?? "",
                "browser": browser
            ])
        } else {
            if result.success {
                print("✓ Opened new tab in \(browser)")
            } else {
                print("✗ Failed to open new tab: \(result.output)")
            }
        }

        if !result.success {
            throw ExitCode.failure
        }
    }
}

struct BrowserCloseTabCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "browser-close-tab",
        abstract: "关闭浏览器当前标签页"
    )

    @Option(name: .long, help: "浏览器名称（默认 Safari）")
    var browser: String = "Safari"

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() throws {
        let script = """
        tell application "\(browser)"
            activate
            tell application "System Events" to keystroke "w" using command down
        end tell
        """

        let result = runAppleScript(script)

        if json {
            printJSON([
                "success": result.success,
                "browser": browser
            ])
        } else {
            if result.success {
                print("✓ Closed current tab in \(browser)")
            } else {
                print("✗ Failed to close tab: \(result.output)")
            }
        }

        if !result.success {
            throw ExitCode.failure
        }
    }
}

private func runAppleScript(_ script: String) -> (success: Bool, output: String) {
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

        return (process.terminationStatus == 0, output)
    } catch {
        return (false, error.localizedDescription)
    }
}
