//
//  TestStartCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct TestStartCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "test-start",
        abstract: "标记测试用例开始"
    )
    
    @Option(name: .shortAndLong, help: "测试用例名称")
    var name: String
    
    @Option(name: .shortAndLong, help: "测试用例 ID")
    var id: String?
    
    @Option(name: .long, help: "测试描述")
    var description: String?
    
    @Flag(name: .long, help: "JSON 输出")
    var json: Bool = false
    
    func run() throws {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        
        if json {
            var output: [String: Any] = [
                "event": "test-start",
                "name": name,
                "timestamp": timestamp
            ]
            if let testId = id { output["id"] = testId }
            if let desc = description { output["description"] = desc }
            printJSON(output)
        } else {
            print("🧪 测试开始: \(name)")
            if let testId = id { print("   ID: \(testId)") }
            if let desc = description { print("   描述: \(desc)") }
            print("   时间: \(timestamp)")
        }
    }
}

struct TestEndCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "test-end",
        abstract: "标记测试用例结束"
    )
    
    @Option(name: .shortAndLong, help: "测试结果 (pass/fail/skip)")
    var result: String
    
    @Option(name: .long, help: "失败原因")
    var reason: String?
    
    @Flag(name: .long, help: "JSON 输出")
    var json: Bool = false
    
    func run() throws {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        
        if json {
            var output: [String: Any] = [
                "event": "test-end",
                "result": result,
                "timestamp": timestamp
            ]
            if let reasonStr = reason { output["reason"] = reasonStr }
            printJSON(output)
        } else {
            let emoji = result == "pass" ? "✅" : result == "fail" ? "❌" : "⏭️"
            print("\(emoji) 测试结束: \(result)")
            if let reasonStr = reason { print("   原因: \(reasonStr)") }
            print("   时间: \(timestamp)")
        }
    }
}

struct StepCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "step",
        abstract: "标记测试步骤"
    )
    
    @Option(name: .shortAndLong, help: "步骤名称")
    var name: String
    
    @Option(name: .long, help: "步骤描述")
    var description: String?
    
    @Flag(name: .long, help: "JSON 输出")
    var json: Bool = false
    
    func run() throws {
        if json {
            var output: [String: Any] = [
                "event": "step",
                "name": name
            ]
            if let desc = description { output["description"] = desc }
            printJSON(output)
        } else {
            print("  📋 步骤: \(name)")
            if let desc = description { print("     \(desc)") }
        }
    }
}
