//
//  ProcessListCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct ProcessListCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "process-list",
        abstract: "列出系统进程"
    )
    
    @Option(name: .long, help: "按名称过滤")
    var filter: String?
    
    @Flag(name: .long, help: "JSON 输出")
    var json: Bool = false
    
    func run() throws {
        var processes = ProcessManager.listProcesses()
        
        if let filter = filter {
            processes = processes.filter { $0.name.lowercased().contains(filter.lowercased()) }
        }
        
        if json {
            if let data = try? JSONEncoder().encode(processes),
               let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
            }
        } else {
            print("进程列表 (共 \(processes.count) 个):")
            print(String(format: "%-10s %-10s %-8s %s", "PID", "PPID", "CPU%", "名称"))
            print(String(repeating: "-", count: 60))
            for process in processes {
                let cpuStr = process.cpuUsage != nil ? String(format: "%.1f", process.cpuUsage!) : "N/A"
                print(String(format: "%-10d %-10d %-8s %s", process.pid, process.ppid, cpuStr, process.name))
            }
        }
    }
}
