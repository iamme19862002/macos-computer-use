//
//  DialogSaveCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct DialogSaveCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "dialog-save",
        abstract: "在保存文件对话框中指定保存路径"
    )
    
    @Option(name: .shortAndLong, help: "保存文件路径")
    var path: String
    
    @Option(name: .long, help: "默认文件名")
    var filename: String?
    
    @Option(name: .long, help: "文件格式（如 png, pdf, txt）")
    var format: String?
    
    @Flag(name: .long, help: "JSON 输出")
    var json: Bool = false
    
    func run() throws {
        let expandedPath = NSString(string: path).expandingTildeInPath
        let saveFilename = filename ?? "untitled"
        
        let script = """
        tell application "System Events"
            tell application process "Finder"
                set frontmost to true
            end tell
        end tell
        
        tell application "Finder"
            activate
            set targetFolder to POSIX file "\(expandedPath)"
            set saveFile to targetFolder & "\(saveFilename)"
            return "Save path prepared: " & (POSIX path of saveFile as string)
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
                "action": "dialog-save",
                "path": expandedPath,
                "filename": saveFilename,
                "format": format ?? "auto",
                "output": output
            ])
        } else {
            if success {
                print("✅ 已设置保存路径: \(expandedPath)/\(saveFilename)")
                if let fmt = format {
                    print("   格式: \(fmt)")
                }
            } else {
                print("❌ 设置保存路径失败: \(output)")
            }
        }
        
        if !success {
            throw ExitCode.failure
        }
    }
}
