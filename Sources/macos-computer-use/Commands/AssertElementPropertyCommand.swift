//
//  AssertElementPropertyCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct AssertElementPropertyCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "assert-element-property",
        abstract: "断言 UI 元素属性值"
    )
    
    @Option(name: .long, help: "元素标题/名称")
    var title: String
    
    @Option(name: .long, help: "属性名 (enabled, focused, value, visible)")
    var property: String
    
    @Option(name: .long, help: "期望值")
    var value: String
    
    @Option(name: .long, help: "目标应用名称")
    var app: String?
    
    @Option(name: .long, help: "超时时间（秒）", transform: { Double($0) ?? 5 })
    var timeout: Double = 5
    
    @Option(name: .long, help: "轮询间隔（秒）", transform: { Double($0) ?? 0.5 })
    var interval: Double = 0.5
    
    @Flag(name: .long, help: "JSON 输出")
    var json: Bool = false
    
    func run() throws {
        let startTime = Date()
        var matched = false
        var foundElement: UIElementInfo? = nil
        var actualValue: String? = nil
        
        while Date().timeIntervalSince(startTime) < timeout {
            let results = AccessibilityManager.findElements(
                byTitle: title,
                inApp: app
            )
            
            if let element = results.first?.info {
                foundElement = element
                let currentValue = getPropertyValue(element, property: property)
                actualValue = currentValue
                
                if currentValue.lowercased() == value.lowercased() {
                    matched = true
                    break
                }
            }
            
            Thread.sleep(forTimeInterval: interval)
        }
        
        let waited = Date().timeIntervalSince(startTime)
        
        if json {
            let output: [String: Any] = [
                "success": matched,
                "assertion": "element-property",
                "element": title,
                "property": property,
                "expected": value,
                "actual": actualValue ?? "null",
                "waited": waited,
                "timeout": timeout
            ]
            printJSON(output)
        } else {
            if matched {
                print("✅ 断言通过：元素「\(title)」的 \(property) = \(value)（等待了 \(String(format: "%.2f", waited)) 秒）")
            } else {
                print("❌ 断言失败：元素「\(title)」的 \(property)")
                print("   期望值: \(value)")
                print("   实际值: \(actualValue ?? "未找到元素")")
                print("   超时: \(timeout) 秒")
                throw ExitCode.failure
            }
        }
        
        if !matched {
            throw ExitCode.failure
        }
    }
    
    private func getPropertyValue(_ element: UIElementInfo, property: String) -> String {
        switch property.lowercased() {
        case "enabled":
            return element.isEnabled ? "true" : "false"
        case "focused":
            return element.isFocused ? "true" : "false"
        case "value":
            return element.value ?? ""
        case "visible":
            return "true" // 如果能找到就是可见的
        case "title":
            return element.title
        case "role":
            return element.role
        default:
            return ""
        }
    }
}
