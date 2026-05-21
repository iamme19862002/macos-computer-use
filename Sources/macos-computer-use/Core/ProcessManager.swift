//
//  ProcessManager.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct ProcessInfo2: Codable {
    let pid: Int
    let name: String
    let ppid: Int
    let cpuUsage: Double?
    let memoryUsage: Int64?
}

struct ProcessManager {
    
    static func listProcesses() -> [ProcessInfo2] {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/ps")
        task.arguments = ["-eo", "pid,ppid,pcpu,pmem,comm"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            guard let output = String(data: data, encoding: .utf8) else { return [] }
            
            var processes: [ProcessInfo2] = []
            let lines = output.components(separatedBy: "\n").dropFirst() // Skip header
            
            for line in lines {
                let components = line.split(separator: " ").filter { !$0.isEmpty }
                guard components.count >= 5,
                      let pid = Int(components[0]),
                      let ppid = Int(components[1]) else { continue }
                
                let cpuUsage = Double(components[2])
                let name = components[4...].joined(separator: " ")
                
                processes.append(ProcessInfo2(
                    pid: pid,
                    name: String(name),
                    ppid: ppid,
                    cpuUsage: cpuUsage,
                    memoryUsage: nil
                ))
            }
            
            return processes
        } catch {
            return []
        }
    }
    
    static func killProcess(pid: Int, force: Bool = false) -> Bool {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/kill")
        task.arguments = force ? ["-9", String(pid)] : [String(pid)]
        
        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            return false
        }
    }
    
    static func findProcesses(named: String) -> [ProcessInfo2] {
        return listProcesses().filter { process in
            process.name.lowercased().contains(named.lowercased())
        }
    }
}
