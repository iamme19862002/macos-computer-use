//
//  ClipboardPasteCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct ClipboardPasteCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "clipboard-paste",
        abstract: "从剪贴板粘贴"
    )
    
    func run() throws {
        if ClipboardManager.paste() {
            print("✅ 已粘贴")
        } else {
            print("❌ 粘贴失败")
            throw ExitCode.failure
        }
    }
}
