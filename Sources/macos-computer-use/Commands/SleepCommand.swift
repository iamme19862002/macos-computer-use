//
//  SleepCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct SleepCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "sleep",
        abstract: "等待指定时间"
    )
    
    @Option(name: .long, help: "等待时间（毫秒）", transform: { Int($0) ?? 1000 })
    var ms: Int = 1000
    
    func run() throws {
        WaitManager.sleep(milliseconds: ms)
    }
}
