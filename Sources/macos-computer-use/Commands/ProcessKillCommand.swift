//
//  ProcessKillCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct ProcessKillCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "process-kill",
        abstract: "结束进程"
    )
    
    @Argument(help: "进程 PID")
    var pid: Int
    
    @Flag(name: .long, help: "强制结束")
    var force: Bool = false
    
    func run() throws {
        if ProcessManager.killProcess(pid: pid, force: force) {
            print("✅ 进程 \(pid) 已\(force ? "强制" : "")结束")
        } else {
            print("❌ 无法结束进程 \(pid)")
            throw ExitCode.failure
        }
    }
}
