//
//  SystemInfoCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct SystemInfoCommand2: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "system-info",
        abstract: "获取系统信息"
    )
    
    @Flag(name: .long, help: "JSON 输出")
    var json: Bool = false
    
    func run() throws {
        let info = SystemInfoManager.getSystemInfo()
        
        if json {
            if let data = try? JSONEncoder().encode(info),
               let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
            }
        } else {
            print("系统信息:")
            print("  OS 版本: \(info.osVersion)")
            print("  Swift 版本: \(info.swiftVersion)")
            print("  CPU 核心数: \(info.cpuCount)")
            print("  物理内存: \(info.physicalMemory / 1024 / 1024) MB")
            print("  主机名: \(info.hostname)")
        }
    }
}
