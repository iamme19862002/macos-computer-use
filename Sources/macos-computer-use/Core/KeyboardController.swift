//
//  KeyboardController.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import CoreGraphics

struct KeyboardController {
    /// 解析键名字符串（xdotool 风格）
    /// "command+c" -> [command, c]
    /// "shift+tab" -> [shift, tab]
    static func parseKeys(_ keyString: String) -> [CGKeyCode] {
        let parts = keyString.split(separator: "+").map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
        return parts.compactMap { KeyMap.cgKeyCode(for: $0) }
    }

    /// 按下并释放一组键（组合键）
    static func pressKeys(_ keys: [CGKeyCode]) {
        guard !keys.isEmpty else { return }

        // 按下所有键
        for key in keys {
            let event = CGEvent(keyboardEventSource: nil, virtualKey: key, keyDown: true)
            event?.post(tap: .cghidEventTap)
        }

        // 短暂延迟确保系统识别组合键
        usleep(50_000) // 50ms

        // 释放所有键（逆序）
        for key in keys.reversed() {
            let event = CGEvent(keyboardEventSource: nil, virtualKey: key, keyDown: false)
            event?.post(tap: .cghidEventTap)
        }
    }

    /// 输入文本字符串
    static func typeText(_ text: String) {
        for char in text {
            if let keyCode = KeyMap.keyCodeForCharacter(char) {
                // 检查是否需要 shift
                let needsShift = char.isUppercase || isShiftedCharacter(char)

                if needsShift {
                    pressKeys([0x38, keyCode]) // shift + key
                } else {
                    pressKeys([keyCode])
                }
            }
        }
    }

    private static func isShiftedCharacter(_ char: Character) -> Bool {
        let shiftedChars: Set<Character> = [
            "!", "@", "#", "$", "%", "^", "&", "*", "(", ")",
            "_", "+", "{", "}", "|", ":", "\"", "<", ">", "?",
            "~"
        ]
        return shiftedChars.contains(char)
    }
}
