//
//  ScrollToElementCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct ScrollToElementCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "scroll-to-element",
        abstract: "滚动直到元素可见"
    )

    @Option(name: .long, help: "应用名称")
    var app: String

    @Option(name: .long, help: "元素标题/名称")
    var name: String?

    @Option(name: .long, help: "元素角色类型")
    var role: String?

    @Option(name: .long, help: "元素标识符")
    var identifier: String?

    @Option(name: .long, help: "最大滚动次数（默认20）")
    var maxScrolls: Int = 20

    @Option(name: .long, help: "每次滚动距离（默认200）")
    var scrollAmount: Int = 200

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() throws {
        guard name != nil || role != nil || identifier != nil else {
            if json {
                printJSON(["success": false, "error": "必须提供 --name、--role 或 --identifier 之一"])
            } else {
                print("✗ 必须提供 --name、--role 或 --identifier 之一")
            }
            throw ExitCode.failure
        }

        var found = false
        var scrollCount = 0

        while scrollCount < maxScrolls {
            let results = AccessibilityManager.findElements(
                byRole: role,
                byTitle: name,
                byIdentifier: identifier,
                inApp: app
            )
            if let result = results.first {
                found = true
                let info = result.info

                if json {
                    printJSON([
                        "success": true,
                        "found": true,
                        "scrolls": scrollCount,
                        "element": [
                            "role": info.role,
                            "title": info.title,
                            "bounds": [
                                "x": info.bounds.x,
                                "y": info.bounds.y,
                                "width": info.bounds.width,
                                "height": info.bounds.height
                            ]
                        ]
                    ])
                } else {
                    print("✓ Element found after \(scrollCount) scrolls: \(info.title) (\(info.role))")
                }
                break
            }

            let currentPos = MouseController.currentPosition()
            MouseController.scroll(
                at: currentPos,
                direction: .down,
                amount: scrollAmount
            )
            WaitManager.sleep(milliseconds: 300)
            scrollCount += 1
        }

        if !found {
            if json {
                printJSON([
                    "success": false,
                    "found": false,
                    "scrolls": scrollCount,
                    "error": "元素未在 \(maxScrolls) 次滚动内找到"
                ])
            } else {
                print("✗ Element not found after \(maxScrolls) scrolls")
            }
            throw ExitCode.failure
        }
    }
}
