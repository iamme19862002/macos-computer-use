//
//  ScreenshotCommand.swift
//  macos-computer-use
//
//  Created by iamme19862002 on 2025.
//  Copyright (c) 2025 iamme19862002. All rights reserved.
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

    func run() async throws {
        let result = ScreenshotTool.capture(outputDir: outputDir, filename: filename)

        if json {
            print(result.jsonString)
        } else {
            if result.success {
                print("✓ Screenshot saved")
                print("  URL: \(result.url)")
                print("  Size: \(result.sizeBytes / 1024) KB")
                print("  Dimensions: \(result.imageWidth)x\(result.imageHeight)")
                print("  Cursor: (\(result.cursorPosition.x), \(result.cursorPosition.y))")
            } else {
                print("✗ Screenshot failed: \(result.error ?? "Unknown error")")
            }
        }
    }
}
