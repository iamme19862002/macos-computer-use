//
//  WindowMaximizeCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct WindowMaximizeCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "window-maximize",
        abstract: "最大化窗口"
    )
    
    @Option(name: .long, help: "应用名称")
    var app: String
    
    @Flag(name: .long, help: "JSON 输出")
    var json: Bool = false
    
    func run() throws {
        let windows = WindowManager.listWindows(options: .onScreen)
        guard let window = windows.first(where: { $0.appName.lowercased().contains(app.lowercased()) }) else {
            throw ValidationError("Window for app '\(app)' not found")
        }
        
        let result = WindowManager.maximize(windowId: window.id)
        
        if json {
            printJSON([
                "success": result.success,
                "windowId": window.id,
                "app": window.appName,
                "message": result.message
            ])
        } else {
            print(result.success ? "✅ \(result.message)" : "❌ \(result.message)")
        }
        
        if !result.success {
            throw ExitCode.failure
        }
    }
}
