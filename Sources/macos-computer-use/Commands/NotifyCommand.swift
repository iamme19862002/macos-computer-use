//
//  NotifyCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation
import UserNotifications

struct NotifyCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "notify",
        abstract: "发送系统通知"
    )

    @Argument(help: "通知标题")
    var title: String

    @Option(name: .shortAndLong, help: "通知内容")
    var message: String?

    @Option(name: .long, help: "通知声音（默认 default）")
    var sound: String = "default"

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() throws {
        let content = message ?? ""

        let script = """
        display notification "\(content)" with title "\(title)" sound name "\(sound)"
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
                    "title": title,
                    "message": content,
                    "sound": sound
                ])
            } else {
                if success {
                    print("✓ Notification sent: \(title)")
                } else {
                    print("✗ Failed to send notification")
                }
            }

            if !success {
                throw ExitCode.failure
            }
        } catch {
            if json {
                printJSON(["success": false, "error": error.localizedDescription])
            } else {
                print("✗ Failed to send notification: \(error.localizedDescription)")
            }
            throw ExitCode.failure
        }
    }
}
