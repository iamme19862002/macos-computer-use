//
//  ClipboardManager.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import AppKit
import Foundation

struct ClipboardManager {
    
    static func copyText(_ text: String) -> Bool {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        return pasteboard.setString(text, forType: .string)
    }
    
    static func getText() -> String? {
        let pasteboard = NSPasteboard.general
        return pasteboard.string(forType: .string)
    }
    
    static func paste() -> Bool {
        KeyboardController.pressKeys([0x37, 0x09]) // command + v
        return true
    }
    
    static func getContents() -> [String: Any] {
        let pasteboard = NSPasteboard.general
        var result: [String: Any] = [:]
        
        if let text = pasteboard.string(forType: .string) {
            result["text"] = text
        }
        
        if let url = pasteboard.string(forType: .URL) {
            result["url"] = url
        }
        
        result["types"] = pasteboard.types?.map { $0.rawValue } ?? []
        
        return result
    }
}
