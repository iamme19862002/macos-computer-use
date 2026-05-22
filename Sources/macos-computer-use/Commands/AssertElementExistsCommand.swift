//
//  AssertElementExistsCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct AssertElementExistsCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "assert-element-exists",
        abstract: "断言 UI 元素存在或不存在"
    )
    
    @Option(name: .long, help: "元素角色")
    var role: String?
    
    @Option(name: .long, help: "元素标题/名称")
    var title: String?
    
    @Option(name: .long, help: "元素标识符")
    var identifier: String?
    
    @Option(name: .long, help: "元素描述")
    var description: String?
    
    @Option(name: .long, help: "目标应用名称")
    var app: String?
    
    @Option(name: .long, help: "超时时间（秒）", transform: { Double($0) ?? 5 })
    var timeout: Double = 5
    
    @Option(name: .long, help: "轮询间隔（秒）", transform: { Double($0) ?? 0.5 })
    var interval: Double = 0.5
    
    @Flag(name: .long, help: "反向断言：断言元素不存在")
    var notExists: Bool = false
    
    @Flag(name: .long, help: "JSON 输出")
    var json: Bool = false
    
    func run() throws {
        let startTime = Date()
        var found = false
        var foundElement: UIElementInfo? = nil
        
        while Date().timeIntervalSince(startTime) < timeout {
            let results = AccessibilityManager.findElements(
                byRole: role,
                byTitle: title,
                byIdentifier: identifier,
                byDescription: description,
                inApp: app
            )
            
            if !results.isEmpty {
                found = true
                foundElement = results.first?.info
                break
            }
            
            if notExists {
                // 如果是反向断言，不需要等待，直接检查一次即可
                break
            }
            
            Thread.sleep(forTimeInterval: interval)
        }
        
        let waited = Date().timeIntervalSince(startTime)
        let success = notExists ? !found : found
        
        if json {
            var output: [String: Any] = [
                "success": success,
                "assertion": notExists ? "element-not-exists" : "element-exists",
                "found": found,
                "waited": waited,
                "timeout": timeout
            ]
            if let element = foundElement {
                output["element"] = [
                    "role": element.role,
                    "title": element.title,
                    "x": element.bounds.x,
                    "y": element.bounds.y,
                    "width": element.bounds.width,
                    "height": element.bounds.height
                ]
            }
            printJSON(output)
        } else {
            if success {
                if notExists {
                    print("✅ 断言通过：元素不存在（等待了 \(String(format: "%.2f", waited)) 秒）")
                } else {
                    print("✅ 断言通过：元素存在（等待了 \(String(format: "%.2f", waited)) 秒）")
                    if let element = foundElement {
                        print("   角色: \(element.role)")
                        print("   标题: \(element.title)")
                        print("   位置: (\(Int(element.bounds.x)), \(Int(element.bounds.y)))")
                    }
                }
            } else {
                if notExists {
                    print("❌ 断言失败：元素仍然存在（等待了 \(String(format: "%.2f", waited)) 秒）")
                } else {
                    print("❌ 断言失败：元素未找到（超时 \(timeout) 秒）")
                }
                throw ExitCode.failure
            }
        }
        
        if !success {
            throw ExitCode.failure
        }
    }
}
