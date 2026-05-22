//
//  FileWriteCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct FileWriteCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "file-write",
        abstract: "写入文件内容"
    )

    @Argument(help: "文件路径")
    var path: String

    @Option(name: .shortAndLong, help: "要写入的文本内容")
    var text: String?

    @Option(name: .long, help: "从 base64 解码后写入")
    var base64: String?

    @Flag(name: .long, help: "追加模式（默认覆盖）")
    var append = false

    @Flag(name: .long, help: "自动创建父目录")
    var createDirs = false

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() throws {
        let expandedPath = NSString(string: path).expandingTildeInPath
        let url = URL(fileURLWithPath: expandedPath)

        if createDirs {
            let dir = url.deletingLastPathComponent()
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }

        var data: Data?

        if let b64 = base64 {
            data = Data(base64Encoded: b64)
            if data == nil {
                if json {
                    printJSON([
                        "success": false,
                        "error": "Invalid base64 string"
                    ])
                } else {
                    print("✗ Invalid base64 string")
                }
                throw ExitCode.failure
            }
        } else if let t = text {
            data = t.data(using: .utf8)
        } else {
            if json {
                printJSON([
                    "success": false,
                    "error": "Must provide either --text or --base64"
                ])
            } else {
                print("✗ Must provide either --text or --base64")
            }
            throw ExitCode.failure
        }

        guard let writeData = data else {
            if json {
                printJSON([
                    "success": false,
                    "error": "Failed to encode data"
                ])
            } else {
                print("✗ Failed to encode data")
            }
            throw ExitCode.failure
        }

        do {
            if append && FileManager.default.fileExists(atPath: expandedPath) {
                let handle = try FileHandle(forWritingTo: url)
                handle.seekToEndOfFile()
                handle.write(writeData)
                handle.closeFile()
            } else {
                try writeData.write(to: url)
            }

            let size = writeData.count

            if json {
                printJSON([
                    "success": true,
                    "path": expandedPath,
                    "size": size,
                    "mode": append ? "append" : "overwrite"
                ])
            } else {
                print("✓ Written \(size) bytes to \(expandedPath)")
            }
        } catch {
            if json {
                printJSON([
                    "success": false,
                    "error": error.localizedDescription
                ])
            } else {
                print("✗ Failed to write file: \(error.localizedDescription)")
            }
            throw ExitCode.failure
        }
    }
}
