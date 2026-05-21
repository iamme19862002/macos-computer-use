//
//  WaitForAppCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct WaitForAppCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "wait-for-app",
        abstract: "等待应用启动"
    )
    
    @Argument(help: "应用名称")
    var appName: String
    
    @Option(name: .long, help: "超时时间（秒）", transform: { Double($0) ?? 10 })
    var timeout: Double = 10
    
    @Flag(name: .long, help: "JSON 输出")
    var json: Bool = false
    
    func run() throws {
        let result = WaitManager.waitForApp(appName: appName, timeout: timeout)
        
        if json {
            let output: [String: Any] = [
                "found": result.found,
                "waited": result.waited,
                "app": appName
            ]
            printJSON(output)
        } else {
            if result.found {
                print("✅ 应用 '\(appName)' 已启动（等待了 \(String(format: "%.2f", result.waited)) 秒）")
            } else {
                print("❌ 应用 '\(appName)' 未启动（超时 \(timeout) 秒）")
                throw ExitCode.failure
            }
        }
    }
}
