//
//  RecordCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct RecordCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "record",
        abstract: "录制操作序列"
    )
    
    @Option(name: .long, help: "输出文件路径")
    var output: String = "recorded_actions.json"
    
    @Option(name: .long, help: "录制时长（秒）", transform: { Double($0) ?? 60 })
    var duration: Double = 60
    
    func run() throws {
        print("🔴 开始录制操作（按 Ctrl+C 停止，或等待 \(Int(duration)) 秒）...")
        
        Recorder.startRecording()
        
        // 简单实现：监听鼠标和键盘事件需要更复杂的实现
        // 这里提供一个基础框架
        Thread.sleep(forTimeInterval: duration)
        
        let actions = Recorder.stopRecording()
        
        if Recorder.saveToFile(output) {
            print("✅ 录制完成，保存了 \(actions.count) 个动作到 \(output)")
        } else {
            print("❌ 保存失败")
            throw ExitCode.failure
        }
    }
}
