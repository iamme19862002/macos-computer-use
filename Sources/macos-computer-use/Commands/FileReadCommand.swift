//
//  FileReadCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct FileReadCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "file-read",
        abstract: "读取文件内容"
    )

    @Argument(help: "文件路径")
    var path: String

    @Flag(name: .long, help: "以 base64 编码输出")
    var base64 = false

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() throws {
        let expandedPath = NSString(string: path).expandingTildeInPath
        let url = URL(fileURLWithPath: expandedPath)

        guard FileManager.default.fileExists(atPath: expandedPath) else {
            if json {
                printJSON([
                    "success": false,
                    "error": "File not found: \(expandedPath)"
                ])
            } else {
                print("✗ File not found: \(expandedPath)")
            }
            throw ExitCode.failure
        }

        guard FileManager.default.isReadableFile(atPath: expandedPath) else {
            if json {
                printJSON([
                    "success": false,
                    "error": "File not readable: \(expandedPath)"
                ])
            } else {
                print("✗ File not readable: \(expandedPath)")
            }
            throw ExitCode.failure
        }

        do {
            let data = try Data(contentsOf: url)
            let size = data.count

            if base64 {
                let encoded = data.base64EncodedString()
                if json {
                    printJSON([
                        "success": true,
                        "path": expandedPath,
                        "size": size,
                        "encoding": "base64",
                        "content": encoded
                    ])
                } else {
                    print(encoded)
                }
            } else {
                if let text = String(data: data, encoding: .utf8) {
                    if json {
                        printJSON([
                            "success": true,
                            "path": expandedPath,
                            "size": size,
                            "encoding": "utf-8",
                            "content": text
                        ])
                    } else {
                        print(text)
                    }
                } else {
                    if json {
                        printJSON([
                            "success": false,
                            "error": "File is not valid UTF-8 text, use --base64 flag"
                        ])
                    } else {
                        print("✗ File is not valid UTF-8 text, use --base64 flag")
                    }
                    throw ExitCode.failure
                }
            }
        } catch {
            if json {
                printJSON([
                    "success": false,
                    "error": error.localizedDescription
                ])
            } else {
                print("✗ Failed to read file: \(error.localizedDescription)")
            }
            throw ExitCode.failure
        }
    }
}
