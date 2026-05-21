//
//  ClipboardCopyCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct ClipboardCopyCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "clipboard-copy",
        abstract: "复制文本到剪贴板"
    )
    
    @Argument(help: "要复制的文本")
    var text: String
    
    func run() throws {
        if ClipboardManager.copyText(text) {
            print("✅ 已复制到剪贴板")
        } else {
            print("❌ 复制失败")
            throw ExitCode.failure
        }
    }
}
