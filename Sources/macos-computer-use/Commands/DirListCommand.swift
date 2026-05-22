//
//  DirListCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct DirItem: Codable {
    let name: String
    let path: String
    let isDirectory: Bool
    let size: Int64
    let modified: Date
}

struct DirListCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "dir-list",
        abstract: "列出目录内容"
    )

    @Argument(help: "目录路径（默认当前目录）")
    var path: String = "."

    @Flag(name: .long, help: "递归列出子目录")
    var recursive = false

    @Flag(name: .long, help: "包含隐藏文件")
    var hidden = false

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() throws {
        let expandedPath = NSString(string: path).expandingTildeInPath
        let url = URL(fileURLWithPath: expandedPath)
        let fm = FileManager.default

        var isDir: ObjCBool = false
        guard fm.fileExists(atPath: expandedPath, isDirectory: &isDir), isDir.boolValue else {
            if json {
                printJSON([
                    "success": false,
                    "error": "Not a directory: \(expandedPath)"
                ])
            } else {
                print("✗ Not a directory: \(expandedPath)")
            }
            throw ExitCode.failure
        }

        do {
            let items = try listDirectory(at: url, recursive: recursive, includeHidden: hidden)

            if json {
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                encoder.dateEncodingStrategy = .iso8601
                let data = try encoder.encode(items)
                print(String(data: data, encoding: .utf8)!)
            } else {
                print("Contents of \(expandedPath) (\(items.count) items):")
                for item in items {
                    let icon = item.isDirectory ? "📁" : "📄"
                    let sizeStr = item.isDirectory ? "" : " (\(formatBytes(item.size)))"
                    print("  \(icon) \(item.name)\(sizeStr)")
                }
            }
        } catch {
            if json {
                printJSON([
                    "success": false,
                    "error": error.localizedDescription
                ])
            } else {
                print("✗ Failed to list directory: \(error.localizedDescription)")
            }
            throw ExitCode.failure
        }
    }

    private func listDirectory(at url: URL, recursive: Bool, includeHidden: Bool) throws -> [DirItem] {
        let fm = FileManager.default
        let contents = try fm.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey], options: includeHidden ? [] : .skipsHiddenFiles)

        var items: [DirItem] = []

        for itemURL in contents.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
            let resourceValues = try itemURL.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey])

            let isDirectory = resourceValues.isDirectory ?? false
            let size = Int64(resourceValues.fileSize ?? 0)
            let modified = resourceValues.contentModificationDate ?? Date()

            let dirItem = DirItem(
                name: itemURL.lastPathComponent,
                path: itemURL.path,
                isDirectory: isDirectory,
                size: size,
                modified: modified
            )
            items.append(dirItem)

            if recursive && isDirectory {
                let subItems = try listDirectory(at: itemURL, recursive: true, includeHidden: includeHidden)
                items.append(contentsOf: subItems)
            }
        }

        return items
    }

    private func formatBytes(_ bytes: Int64) -> String {
        let units = ["B", "KB", "MB", "GB"]
        var size = Double(bytes)
        var unitIndex = 0
        while size >= 1024 && unitIndex < units.count - 1 {
            size /= 1024
            unitIndex += 1
        }
        return String(format: "%.1f %@", size, units[unitIndex])
    }
}
