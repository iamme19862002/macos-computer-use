//
//  FileExistsCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct FileExistsCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "file-exists",
        abstract: "检查文件或目录是否存在"
    )

    @Argument(help: "文件或目录路径")
    var path: String

    @Flag(name: .long, help: "检查是否为目录")
    var directory = false

    @Flag(name: .long, help: "检查是否为文件")
    var file = false

    @Flag(name: .long, help: "反向断言：断言不存在")
    var notExists = false

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() throws {
        let expandedPath = NSString(string: path).expandingTildeInPath
        let fm = FileManager.default
        var exists = false
        var isDir: ObjCBool = false

        exists = fm.fileExists(atPath: expandedPath, isDirectory: &isDir)

        if directory && exists {
            exists = isDir.boolValue
        }
        if file && exists {
            exists = !isDir.boolValue
        }

        let success = notExists ? !exists : exists

        if json {
            var output: [String: Any] = [
                "success": success,
                "path": expandedPath,
                "exists": exists,
                "isDirectory": isDir.boolValue
            ]
            if directory {
                output["checkType"] = "directory"
            } else if file {
                output["checkType"] = "file"
            } else {
                output["checkType"] = "any"
            }
            printJSON(output)
        } else {
            if success {
                if notExists {
                    print("✓ Path does not exist: \(expandedPath)")
                } else {
                    let type = isDir.boolValue ? "directory" : "file"
                    print("✓ Path exists: \(expandedPath) (\(type))")
                }
            } else {
                if notExists {
                    print("✗ Path still exists: \(expandedPath)")
                } else {
                    print("✗ Path not found: \(expandedPath)")
                }
            }
        }

        if !success {
            throw ExitCode.failure
        }
    }
}
