//
//  ReplayCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct ReplayCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "replay",
        abstract: "回放录制的操作"
    )
    
    @Option(name: .long, help: "脚本文件路径")
    var file: String
    
    func run() throws {
        guard let actions = Recorder.loadFromFile(file) else {
            print("❌ 无法加载脚本文件: \(file)")
            throw ExitCode.failure
        }
        
        print("▶️ 开始回放 \(actions.count) 个动作...")
        
        var lastTimestamp: Double = 0
        for action in actions {
            let delay = action.timestamp - lastTimestamp
            if delay > 0 {
                Thread.sleep(forTimeInterval: delay)
            }
            lastTimestamp = action.timestamp
            
            print("执行: \(action.type) \(action.params)")
            
            // 根据类型执行相应操作
            switch action.type {
            case "mouse-move":
                if let x = action.params["x"], let y = action.params["y"],
                   let xVal = Double(x), let yVal = Double(y) {
                    MouseController.moveTo(x: Int(xVal), y: Int(yVal))
                }
            case "click":
                if let x = action.params["x"], let y = action.params["y"],
                   let xVal = Double(x), let yVal = Double(y) {
                    MouseController.leftClick(at: CGPoint(x: xVal, y: yVal))
                } else {
                    MouseController.leftClick()
                }
            case "key":
                if let keys = action.params["keys"] {
                    let keyCodes = KeyboardController.parseKeys(keys)
                    KeyboardController.pressKeys(keyCodes)
                }
            case "type":
                if let text = action.params["text"] {
                    KeyboardController.typeText(text)
                }
            case "sleep":
                if let ms = action.params["ms"], let msVal = Int(ms) {
                    WaitManager.sleep(milliseconds: msVal)
                }
            default:
                print("  ⚠️ 未知动作类型: \(action.type)")
            }
        }
        
        print("✅ 回放完成")
    }
}
