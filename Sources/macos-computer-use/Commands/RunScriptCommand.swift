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

enum ScriptConditionOp: String, Codable {
    case eq, ne, gt, lt, gte, lte, contains, exists
}

struct ScriptCondition: Codable {
    let op: String
    let left: String
    let right: String?
}

struct ScriptStep: Codable {
    let action: String
    let params: [String: String]?
    let id: String?
    let if_: ScriptCondition?
    let forEach: String?
    let in_: String?
    let while_: ScriptCondition?
    let retry: Int?
    let retryInterval: Int?

    enum CodingKeys: String, CodingKey {
        case action, params, id, forEach, retry, retryInterval
        case if_ = "if"
        case in_ = "in"
        case while_ = "while"
    }
}

struct ScriptContext {
    var variables: [String: String] = [:]
    var outputs: [String: Any] = [:]

    mutating func setVariable(_ name: String, value: String) {
        variables[name] = value
    }

    func resolve(_ template: String) -> String {
        var result = template
        for (key, value) in variables {
            result = result.replacingOccurrences(of: "{{\(key)}}", with: value)
            result = result.replacingOccurrences(of: "${\(key)}", with: value)
        }
        return result
    }
}

struct RunScriptCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "run-script",
        abstract: "执行增强型 JSON 脚本文件（支持变量、条件、循环）"
    )

    @Option(name: .long, help: "脚本文件路径")
    var file: String

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    @Flag(name: .long, help: "仅验证脚本语法不执行")
    var dryRun = false

    func run() throws {
        let expandedPath = NSString(string: file).expandingTildeInPath
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: expandedPath)),
              let steps = try? JSONDecoder().decode([ScriptStep].self, from: data) else {
            if json {
                printJSON(["success": false, "error": "无法加载或解析脚本文件: \(expandedPath)"])
            } else {
                print("✗ 无法加载或解析脚本文件: \(expandedPath)")
            }
            throw ExitCode.failure
        }

        if dryRun {
            if json {
                printJSON(["success": true, "steps": steps.count, "message": "脚本语法验证通过"])
            } else {
                print("✓ 脚本语法验证通过（\(steps.count) 个步骤）")
            }
            return
        }

        if !json {
            print("▶ 开始执行脚本（共 \(steps.count) 个步骤）...")
        }

        var context = ScriptContext()
        var stepResults: [[String: Any]] = []

        for (index, step) in steps.enumerated() {
            let stepId = step.id ?? "step_\(index + 1)"

            if let condition = step.if_ {
                if !evaluateCondition(condition, context: context) {
                    stepResults.append(["id": stepId, "action": step.action, "skipped": true, "reason": "condition_not_met"])
                    continue
                }
            }

            if let forEachKey = step.forEach, let inKey = step.in_ {
                let items = inKey.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
                for item in items {
                    context.setVariable(forEachKey, value: item)
                    let result = executeStep(step, context: &context, stepIndex: index, json: json)
                    stepResults.append(["id": "\(stepId)_\(item)", "action": step.action, "success": result])
                }
                continue
            }

            if let whileCondition = step.while_ {
                var loopCount = 0
                let maxLoops = 100
                while evaluateCondition(whileCondition, context: context) && loopCount < maxLoops {
                    let result = executeStep(step, context: &context, stepIndex: index, json: json)
                    stepResults.append(["id": "\(stepId)_\(loopCount)", "action": step.action, "success": result])
                    loopCount += 1
                }
                if loopCount >= maxLoops {
                    stepResults.append(["id": stepId, "action": step.action, "warning": "max_loop_reached"])
                }
                continue
            }

            let retryCount = step.retry ?? 1
            let retryInterval = step.retryInterval ?? 1000
            var success = false

            for attempt in 1...retryCount {
                success = executeStep(step, context: &context, stepIndex: index, json: json)
                if success {
                    break
                }
                if attempt < retryCount {
                    WaitManager.sleep(milliseconds: retryInterval)
                }
            }

            stepResults.append(["id": stepId, "action": step.action, "success": success, "attempts": retryCount])
        }

        if json {
            printJSON([
                "success": true,
                "totalSteps": steps.count,
                "results": stepResults,
                "variables": context.variables
            ] as [String: Any])
        } else {
            print("✓ 脚本执行完成")
        }
    }

    private func evaluateCondition(_ condition: ScriptCondition, context: ScriptContext) -> Bool {
        let leftValue = context.resolve(condition.left)
        let rightValue = context.resolve(condition.right ?? "")

        switch condition.op {
        case "eq": return leftValue == rightValue
        case "ne": return leftValue != rightValue
        case "gt": return Double(leftValue) ?? 0 > Double(rightValue) ?? 0
        case "lt": return Double(leftValue) ?? 0 < Double(rightValue) ?? 0
        case "gte": return Double(leftValue) ?? 0 >= Double(rightValue) ?? 0
        case "lte": return Double(leftValue) ?? 0 <= Double(rightValue) ?? 0
        case "contains": return leftValue.contains(rightValue)
        case "exists": return !leftValue.isEmpty
        default: return false
        }
    }

    private func executeStep(_ step: ScriptStep, context: inout ScriptContext, stepIndex: Int, json: Bool) -> Bool {
        var params = step.params ?? [:]
        for (key, value) in params {
            params[key] = context.resolve(value)
        }

        if !json {
            print("[\(stepIndex + 1)] \(step.action)")
        }

        switch step.action {
        case "set-variable":
            if let name = params["name"], let value = params["value"] {
                context.setVariable(name, value: value)
                return true
            }
            return false

        case "mouse-move":
            if let x = params["x"], let y = params["y"],
               let xVal = Double(x), let yVal = Double(y) {
                MouseController.moveTo(x: Int(xVal), y: Int(yVal))
                return true
            }
            return false

        case "click":
            if let x = params["x"], let y = params["y"],
               let xVal = Double(x), let yVal = Double(y) {
                MouseController.leftClick(at: CGPoint(x: xVal, y: yVal))
            } else {
                MouseController.leftClick()
            }
            return true

        case "right-click":
            if let x = params["x"], let y = params["y"],
               let xVal = Double(x), let yVal = Double(y) {
                MouseController.rightClick(at: CGPoint(x: xVal, y: yVal))
            } else {
                MouseController.rightClick()
            }
            return true

        case "double-click":
            if let x = params["x"], let y = params["y"],
               let xVal = Double(x), let yVal = Double(y) {
                MouseController.doubleClick(at: CGPoint(x: xVal, y: yVal))
            } else {
                MouseController.doubleClick()
            }
            return true

        case "drag":
            if let toX = params["toX"], let toY = params["toY"],
               let toXVal = Double(toX), let toYVal = Double(toY) {
                let current = MouseController.currentPosition()
                MouseController.drag(from: current, to: CGPoint(x: CGFloat(toXVal), y: CGFloat(toYVal)))
                return true
            }
            return false

        case "scroll":
            if let x = params["x"], let y = params["y"],
               let xVal = Double(x), let yVal = Double(y),
               let amount = params["amount"], let amountVal = Int(amount),
               let directionStr = params["direction"],
               let direction = ScrollDirection(rawValue: directionStr) {
                MouseController.scroll(at: CGPoint(x: CGFloat(xVal), y: CGFloat(yVal)), direction: direction, amount: amountVal)
                return true
            }
            return false

        case "key":
            if let keys = params["keys"] {
                let keyCodes = KeyboardController.parseKeys(keys)
                KeyboardController.pressKeys(keyCodes)
                return true
            }
            return false

        case "type":
            if let text = params["text"] {
                KeyboardController.typeText(text)
                return true
            }
            return false

        case "sleep":
            if let ms = params["ms"], let msVal = Int(ms) {
                WaitManager.sleep(milliseconds: msVal)
                return true
            }
            return false

        case "screenshot":
            let outputDir = params["outputDir"]
            let filename = params["filename"] ?? "screenshot_\(Int(Date().timeIntervalSince1970)).png"
            _ = ScreenshotTool.capture(outputDir: outputDir, filename: filename)
            return true

        case "app-launch":
            if let appName = params["app"] {
                _ = AppManager.launch(appName: appName)
                return true
            }
            return false

        case "app-quit":
            if let appName = params["app"] {
                _ = AppManager.quit(appName: appName)
                return true
            }
            return false

        case "app-activate":
            if let appName = params["app"] {
                _ = AppManager.activate(appName: appName)
                return true
            }
            return false

        case "clipboard-copy":
            if let text = params["text"] {
                _ = ClipboardManager.copyText(text)
                return true
            }
            return false

        case "clipboard-paste":
            _ = ClipboardManager.paste()
            return true

        default:
            if !json {
                print("  ⚠️ 未知动作类型: \(step.action)")
            }
            return false
        }
    }
}
