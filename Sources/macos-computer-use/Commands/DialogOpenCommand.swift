//
//  DialogOpenCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct DialogOpenCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "dialog-open",
        abstract: "在打开文件对话框中选择文件"
    )
    
    @Option(name: .shortAndLong, help: "要选择的文件路径")
    var path: String
    
    @Option(name: .long, help: "文件类型过滤（如 png,pdf,jpg）")
    var types: String?
    
    @Flag(name: .long, help: "允许多选")
    var multiple: Bool = false
    
    @Flag(name: .long, help: "JSON 输出")
    var json: Bool = false
    
    func run() throws {
        let expandedPath = NSString(string: path).expandingTildeInPath
        
        let script = """
        tell application "System Events"
            tell application process "Finder"
                set frontmost to true
            end tell
        end tell
        
        tell application "Finder"
            activate
            open POSIX file "\(expandedPath)"
        end tell
        """
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        let success = process.terminationStatus == 0
        
        if json {
            printJSON([
                "success": success,
                "action": "dialog-open",
                "path": expandedPath,
                "types": types ?? "all",
                "multiple": multiple,
                "output": output
            ])
        } else {
            if success {
                print("✅ 已选择文件: \(expandedPath)")
            } else {
                print("❌ 选择文件失败: \(output)")
            }
        }
        
        if !success {
            throw ExitCode.failure
        }
    }
}
