//
//  RunScriptCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct ScriptAction: Codable {
    let action: String
    let params: [String: String]?
}

struct RunScriptCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "run-script",
        abstract: "执行 JSON 脚本文件"
    )
    
    @Option(name: .long, help: "脚本文件路径")
    var file: String
    
    func run() throws {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: file)),
              let actions = try? JSONDecoder().decode([ScriptAction].self, from: data) else {
            print("❌ 无法加载脚本文件: \(file)")
            throw ExitCode.failure
        }
        
        print("▶️ 开始执行脚本（共 \(actions.count) 个动作）...")
        
        for (index, action) in actions.enumerated() {
            let params = action.params ?? [:]
            print("[\(index + 1)/\(actions.count)] \(action.action)")
            
            switch action.action {
            case "mouse-move":
                if let x = params["x"], let y = params["y"],
                   let xVal = Double(x), let yVal = Double(y) {
                    MouseController.moveTo(x: Int(xVal), y: Int(yVal))
                }
            case "click":
                if let x = params["x"], let y = params["y"],
                   let xVal = Double(x), let yVal = Double(y) {
                    MouseController.leftClick(at: CGPoint(x: xVal, y: yVal))
                } else {
                    MouseController.leftClick()
                }
            case "right-click":
                if let x = params["x"], let y = params["y"],
                   let xVal = Double(x), let yVal = Double(y) {
                    MouseController.rightClick(at: CGPoint(x: xVal, y: yVal))
                } else {
                    MouseController.rightClick()
                }
            case "double-click":
                if let x = params["x"], let y = params["y"],
                   let xVal = Double(x), let yVal = Double(y) {
                    MouseController.doubleClick(at: CGPoint(x: xVal, y: yVal))
                } else {
                    MouseController.doubleClick()
                }
            case "drag":
                if let toX = params["toX"], let toY = params["toY"],
                   let toXVal = Double(toX), let toYVal = Double(toY) {
                    let current = MouseController.currentPosition()
                    MouseController.drag(from: current, to: CGPoint(x: CGFloat(toXVal), y: CGFloat(toYVal)))
                }
            case "scroll":
                if let x = params["x"], let y = params["y"],
                   let xVal = Double(x), let yVal = Double(y),
                   let amount = params["amount"], let amountVal = Int(amount),
                   let directionStr = params["direction"],
                   let direction = ScrollDirection(rawValue: directionStr) {
                    MouseController.scroll(at: CGPoint(x: CGFloat(xVal), y: CGFloat(yVal)), direction: direction, amount: amountVal)
                }
            case "key":
                if let keys = params["keys"] {
                    let keyCodes = KeyboardController.parseKeys(keys)
                    KeyboardController.pressKeys(keyCodes)
                }
            case "type":
                if let text = params["text"] {
                    KeyboardController.typeText(text)
                }
            case "sleep":
                if let ms = params["ms"], let msVal = Int(ms) {
                    WaitManager.sleep(milliseconds: msVal)
                }
            case "screenshot":
                let outputDir = params["outputDir"]
                let filename = params["filename"] ?? "screenshot_\(Int(Date().timeIntervalSince1970)).png"
                _ = ScreenshotTool.capture(outputDir: outputDir, filename: filename)
            case "app-launch":
                if let appName = params["app"] {
                    _ = AppManager.launch(appName: appName)
                }
            case "app-quit":
                if let appName = params["app"] {
                    _ = AppManager.quit(appName: appName)
                }
            case "app-activate":
                if let appName = params["app"] {
                    _ = AppManager.activate(appName: appName)
                }
            case "clipboard-copy":
                if let text = params["text"] {
                    _ = ClipboardManager.copyText(text)
                }
            case "clipboard-paste":
                _ = ClipboardManager.paste()
            default:
                print("  ⚠️ 未知动作类型: \(action.action)")
            }
        }
        
        print("✅ 脚本执行完成")
    }
}
