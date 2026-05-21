//
//  ScreenshotCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser

struct ScreenshotCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "screenshot",
        abstract: "截取屏幕并返回 file:// URL"
    )

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    @Option(name: .shortAndLong, help: "输出目录")
    var outputDir: String?

    @Option(name: .shortAndLong, help: "自定义文件名")
    var filename: String?

    @Option(name: .long, help: "截取指定区域 (格式: x,y,width,height)")
    var region: String?

    @Option(name: .long, help: "截取指定窗口 ID")
    var windowId: UInt32?

    @Flag(name: .long, help: "标记 UI 元素")
    var markElements = false

    func run() async throws {
        let result = ScreenshotTool.capture(
            outputDir: outputDir,
            filename: filename,
            region: region,
            windowId: windowId,
            markElements: markElements
        )

        if json {
            print(result.jsonString)
        } else {
            if result.success {
                print("✓ Screenshot saved")
                print("  URL: \(result.url)")
                print("  Size: \(result.sizeBytes / 1024) KB")
                print("  Dimensions: \(result.imageWidth)x\(result.imageHeight)")
                print("  Cursor: (\(result.cursorPosition.x), \(result.cursorPosition.y))")
                if region != nil {
                    print("  Region: \(region!)")
                }
                if windowId != nil {
                    print("  Window ID: \(windowId!)")
                }
                if markElements {
                    print("  Elements: marked")
                }
            } else {
                print("✗ Screenshot failed: \(result.error ?? "Unknown error")")
            }
        }
    }
}
