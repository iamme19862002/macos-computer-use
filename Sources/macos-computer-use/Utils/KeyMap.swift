//
//  KeyMap.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import CoreGraphics

/// xdotool 风格键名到 CGKeyCode 的映射
struct KeyMap {
    private static let map: [String: CGKeyCode] = [
        // Modifiers
        "command": 0x37, "cmd": 0x37,
        "shift": 0x38, "shift_l": 0x38, "l_shift": 0x38,
        "option": 0x3A, "alt": 0x3A, "option_l": 0x3A, "alt_l": 0x3A,
        "control": 0x3B, "ctrl": 0x3B, "control_l": 0x3B, "ctrl_l": 0x3B,
        "right_shift": 0x3C, "shift_r": 0x3C, "r_shift": 0x3C,
        "right_option": 0x3D, "option_r": 0x3D, "alt_r": 0x3D, "r_alt": 0x3D,
        "right_control": 0x3E, "control_r": 0x3E, "ctrl_r": 0x3E, "r_control": 0x3E,
        "fn": 0x3F,

        // Navigation
        "return": 0x24, "enter": 0x24,
        "tab": 0x30,
        "space": 0x31,
        "backspace": 0x33, "delete": 0x33,
        "escape": 0x35, "esc": 0x35,
        "forward_delete": 0x75, "forwarddelete": 0x75, "del": 0x75,
        "left": 0x7B,
        "right": 0x7C,
        "down": 0x7D,
        "up": 0x7E,
        "home": 0x73,
        "end": 0x77,
        "page_up": 0x74, "pageup": 0x74, "prior": 0x74,
        "page_down": 0x79, "pagedown": 0x79, "next": 0x79,
        "insert": 0x72, "ins": 0x72,

        // Function keys
        "f1": 0x7A, "f2": 0x78, "f3": 0x63, "f4": 0x76,
        "f5": 0x60, "f6": 0x61, "f7": 0x62, "f8": 0x64,
        "f9": 0x65, "f10": 0x6D, "f11": 0x67, "f12": 0x6F,
        "f13": 0x69, "f14": 0x6B, "f15": 0x71,

        // Letters
        "a": 0x00, "b": 0x0B, "c": 0x08, "d": 0x02,
        "e": 0x0E, "f": 0x03, "g": 0x05, "h": 0x04,
        "i": 0x22, "j": 0x26, "k": 0x28, "l": 0x25,
        "m": 0x2E, "n": 0x2D, "o": 0x1F, "p": 0x23,
        "q": 0x0C, "r": 0x0F, "s": 0x01, "t": 0x11,
        "u": 0x20, "v": 0x09, "w": 0x0D, "x": 0x07,
        "y": 0x10, "z": 0x06,

        // Numbers
        "0": 0x1D, "1": 0x12, "2": 0x13, "3": 0x14,
        "4": 0x15, "5": 0x17, "6": 0x16, "7": 0x1A,
        "8": 0x1C, "9": 0x19,

        // Punctuation
        "minus": 0x1B, "equal": 0x18,
        "bracketleft": 0x21, "bracketright": 0x1E,
        "backslash": 0x2A, "semicolon": 0x29,
        "quote": 0x27, "grave": 0x32,
        "comma": 0x2B, "period": 0x2F, "slash": 0x2C,
    ]

    static func cgKeyCode(for key: String) -> CGKeyCode? {
        return map[key.lowercased()]
    }

    static func keyCodeForCharacter(_ char: Character) -> CGKeyCode? {
        return map[String(char).lowercased()]
    }
}
