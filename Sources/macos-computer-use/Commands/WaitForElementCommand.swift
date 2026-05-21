//
//  WaitForElementCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct WaitForElementCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "wait-for-element",
        abstract: "等待 UI 元素出现"
    )
    
    @Option(name: .long, help: "元素角色")
    var role: String?
    
    @Option(name: .long, help: "元素标题")
    var title: String?
    
    @Option(name: .long, help: "元素标识符")
    var identifier: String?
    
    @Option(name: .long, help: "元素描述")
    var description: String?
    
    @Option(name: .long, help: "目标应用名称")
    var app: String?
    
    @Option(name: .long, help: "超时时间（秒）", transform: { Double($0) ?? 10 })
    var timeout: Double = 10
    
    @Option(name: .long, help: "轮询间隔（秒）", transform: { Double($0) ?? 0.5 })
    var interval: Double = 0.5
    
    @Flag(name: .long, help: "JSON 输出")
    var json: Bool = false
    
    func run() throws {
        let result = WaitManager.waitForElement(
            role: role,
            title: title,
            identifier: identifier,
            description: description,
            inApp: app,
            timeout: timeout,
            interval: interval
        )
        
        if json {
            var output: [String: Any] = [
                "found": result.found,
                "waited": result.waited
            ]
            if let element = result.element {
                let elementDict: [String: Any] = [
                    "role": element.role,
                    "title": element.title,
                    "identifier": element.identifier ?? "",
                    "x": element.bounds.x,
                    "y": element.bounds.y,
                    "width": element.bounds.width,
                    "height": element.bounds.height
                ]
                output["element"] = elementDict
            }
            printJSON(output)
        } else {
            if result.found, let element = result.element {
                print("✅ 元素已找到（等待了 \(String(format: "%.2f", result.waited)) 秒）")
                print("   角色: \(element.role)")
                print("   标题: \(element.title)")
                print("   位置: (\(Int(element.bounds.x)), \(Int(element.bounds.y)))")
            } else {
                print("❌ 元素未找到（超时 \(timeout) 秒）")
                throw ExitCode.failure
            }
        }
    }
}
