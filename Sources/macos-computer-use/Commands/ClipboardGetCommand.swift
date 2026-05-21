//
//  ClipboardGetCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct ClipboardGetCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "clipboard-get",
        abstract: "获取剪贴板内容"
    )
    
    @Flag(name: .long, help: "JSON 输出")
    var json: Bool = false
    
    func run() throws {
        let contents = ClipboardManager.getContents()
        
        if json {
            printJSON(contents)
        } else {
            if let text = contents["text"] as? String {
                print(text)
            } else {
                print("(剪贴板中没有文本)")
            }
        }
    }
}
