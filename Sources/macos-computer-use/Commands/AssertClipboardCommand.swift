//
//  AssertClipboardCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct AssertClipboardCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "assert-clipboard",
        abstract: "断言剪贴板内容"
    )
    
    @Option(name: .long, help: "期望包含的文本")
    var contains: String?
    
    @Option(name: .long, help: "期望完全匹配的文本")
    var equals: String?
    
    @Flag(name: .long, help: "断言剪贴板不为空")
    var notEmpty: Bool = false
    
    @Flag(name: .long, help: "JSON 输出")
    var json: Bool = false
    
    func run() throws {
        let clipboardContent = ClipboardManager.getText() ?? ""
        
        var success = false
        var assertionType = ""
        var expectedValue = ""
        
        if let expected = equals {
            success = clipboardContent == expected
            assertionType = "equals"
            expectedValue = expected
        } else if let expected = contains {
            success = clipboardContent.contains(expected)
            assertionType = "contains"
            expectedValue = expected
        } else if notEmpty {
            success = !clipboardContent.isEmpty
            assertionType = "not-empty"
        } else {
            throw ValidationError("请指定 --contains, --equals 或 --not-empty 之一")
        }
        
        if json {
            let output: [String: Any] = [
                "success": success,
                "assertion": assertionType,
                "expected": expectedValue,
                "actual": clipboardContent,
                "clipboardEmpty": clipboardContent.isEmpty
            ]
            printJSON(output)
        } else {
            if success {
                print("✅ 断言通过：剪贴板内容符合预期")
                if !clipboardContent.isEmpty {
                    let preview = clipboardContent.prefix(100)
                    print("   内容: \(preview)\(clipboardContent.count > 100 ? "..." : "")")
                }
            } else {
                print("❌ 断言失败：剪贴板内容不符合预期")
                print("   断言类型: \(assertionType)")
                if !expectedValue.isEmpty {
                    print("   期望值: \(expectedValue)")
                }
                print("   实际值: \(clipboardContent.isEmpty ? "(空)" : clipboardContent)")
                throw ExitCode.failure
            }
        }
        
        if !success {
            throw ExitCode.failure
        }
    }
}
