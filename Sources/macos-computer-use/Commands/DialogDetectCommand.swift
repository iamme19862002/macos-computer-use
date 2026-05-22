//
//  DialogDetectCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct DialogDetectCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "dialog-detect",
        abstract: "检测系统弹窗（权限弹窗、确认对话框等）"
    )

    @Option(name: .long, help: "弹窗标题关键词过滤")
    var title: String?

    @Option(name: .long, help: "弹窗按钮文本过滤")
    var button: String?

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() throws {
        let script = """
        tell application "System Events"
            set dialogs to {}
            set allProcesses to every application process whose background only is false
            repeat with proc in allProcesses
                try
                    set procWindows to every window of proc
                    repeat with win in procWindows
                        try
                            set winTitle to name of win
                            set winRole to value of attribute "AXRole" of win
                            if winRole is "AXSheet" or winRole is "AXDialog" or winRole is "AXSystemDialog" then
                                set dialogInfo to {processName:(name of proc), title:winTitle, role:winRole}
                                set end of dialogs to dialogInfo
                            end if
                        end try
                    end repeat
                end try
            end repeat
            return dialogs
        end tell
        """

        let result = runAppleScript(script)
        let output = result.output.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasDialogs = !output.isEmpty && output != "{}" && output != ""

        var filtered = hasDialogs
        if let titleFilter = title, hasDialogs {
            filtered = output.localizedCaseInsensitiveContains(titleFilter)
        }
        if let buttonFilter = button, hasDialogs {
            filtered = output.localizedCaseInsensitiveContains(buttonFilter)
        }

        if json {
            printJSON([
                "success": true,
                "detected": filtered,
                "dialogs": output,
                "titleFilter": title ?? "",
                "buttonFilter": button ?? ""
            ])
        } else {
            if filtered {
                print("⚠️  Detected system dialog(s)")
                print(output)
            } else {
                print("✓ No matching dialogs detected")
            }
        }
    }
}

struct DialogDismissCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "dialog-dismiss",
        abstract: "关闭/取消系统弹窗"
    )

    @Option(name: .long, help: "点击指定按钮文本（默认取消/不允许）")
    var click: String?

    @Flag(name: .long, help: "强制关闭（按 Escape 键）")
    var escape = false

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() throws {
        let script: String

        if let buttonText = click {
            script = """
            tell application "System Events"
                set frontApp to first application process whose frontmost is true
                tell frontApp
                    try
                        click button "\(buttonText)" of front window
                    on error
                        keystroke "\(buttonText)"
                    end try
                end tell
            end tell
            """
        } else if escape {
            script = """
            tell application "System Events"
                key code 53
            end tell
            """
        } else {
            script = """
            tell application "System Events"
                set frontApp to first application process whose frontmost is true
                tell frontApp
                    try
                        click button "取消" of front window
                    on error
                        try
                            click button "不允许" of front window
                        on error
                            try
                                click button "Don't Allow" of front window
                            on error
                                try
                                    click button "Cancel" of front window
                                on error
                                    key code 53
                                end try
                            end try
                        end try
                    end try
                end tell
            end tell
            """
        }

        let result = runAppleScript(script)
        let success = result.success

        if json {
            printJSON([
                "success": success,
                "method": escape ? "escape" : (click != nil ? "click:\(click!)" : "auto"),
                "output": result.output.trimmingCharacters(in: .whitespacesAndNewlines)
            ])
        } else {
            if success {
                print("✓ Dialog dismissed")
            } else {
                print("✗ Failed to dismiss dialog: \(result.output)")
            }
        }

        if !success {
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
