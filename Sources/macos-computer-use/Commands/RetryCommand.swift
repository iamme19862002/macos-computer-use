//
//  RetryCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct RetryCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "retry",
        abstract: "重试执行命令直到成功或达到最大次数"
    )
    
    @Option(name: .shortAndLong, help: "最大重试次数", transform: { Int($0) ?? 3 })
    var attempts: Int = 3
    
    @Option(name: .shortAndLong, help: "重试间隔（秒）", transform: { Double($0) ?? 1.0 })
    var interval: Double = 1.0
    
    @Option(name: .shortAndLong, help: "要执行的子命令（如 'click --app Safari --target 刷新'）")
    var command: String
    
    @Flag(name: .long, help: "JSON 输出")
    var json: Bool = false
    
    func run() throws {
        var lastError: Error?
        
        for attempt in 1...attempts {
            do {
                // 执行子命令
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/local/bin/macos-computer-use")
                process.arguments = command.split(separator: " ").map { String($0) }
                
                let pipe = Pipe()
                process.standardOutput = pipe
                process.standardError = pipe
                
                try process.run()
                process.waitUntilExit()
                
                if process.terminationStatus == 0 {
                    if json {
                        printJSON([
                            "success": true,
                            "attempts": attempt,
                            "command": command
                        ])
                    } else {
                        print("✅ 重试成功：第 \(attempt) 次尝试成功")
                    }
                    return
                } else {
                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    let output = String(data: data, encoding: .utf8) ?? ""
                    throw ValidationError("Command failed: \(output)")
                }
            } catch {
                lastError = error
                if attempt < attempts {
                    if !json {
                        print("⚠️ 第 \(attempt) 次尝试失败，\(interval) 秒后重试...")
                    }
                    Thread.sleep(forTimeInterval: interval)
                }
            }
        }
        
        if json {
            printJSON([
                "success": false,
                "attempts": attempts,
                "command": command,
                "error": lastError?.localizedDescription ?? "Unknown error"
            ])
        } else {
            print("❌ 重试失败：经过 \(attempts) 次尝试后仍然失败")
            if let error = lastError {
                print("   最后错误: \(error.localizedDescription)")
            }
        }
        
        throw ExitCode.failure
    }
}
