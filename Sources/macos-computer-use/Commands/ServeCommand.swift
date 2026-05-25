//
//  ServeCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

struct ServeCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "serve",
        abstract: "启动 MCP Server 模式（stdin/stdout JSON-RPC）"
    )

    @Option(name: .long, help: "监听端口（默认不启动 HTTP，仅使用 stdin/stdout）")
    var port: Int?

    @Option(name: .long, help: "日志级别（debug/info/warn/error）")
    var logLevel: String = "info"

    func run() async throws {
        let server = MCPServer(logLevel: logLevel)
        await server.run()
    }
}

actor MCPServer {
    let logLevel: String
    var isRunning = true

    init(logLevel: String) {
        self.logLevel = logLevel
    }

    func run() async {
        log("MCP Server started (macos-computer-use v3.3.1)")
        log("Protocol: JSON-RPC 2.0 over stdin/stdout")

        let stdin = FileHandle.standardInput
        while isRunning {
            guard let line = readLine() else {
                try? await Task.sleep(nanoseconds: 10_000_000)
                continue
            }

            guard let data = line.data(using: .utf8),
                  let request = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let method = request["method"] as? String else {
                sendError(id: nil, code: -32700, message: "Parse error")
                continue
            }

            let id = request["id"]
            let params = request["params"] as? [String: Any] ?? [:]

            await handleRequest(method: method, params: params, id: id)
        }
    }

    private func handleRequest(method: String, params: [String: Any], id: Any?) async {
        log("Request: \(method)")

        switch method {
        case "initialize":
            sendResponse(id: id, result: [
                "protocolVersion": "2024-11-05",
                "capabilities": [
                    "tools": ["listChanged": true]
                ],
                "serverInfo": [
                    "name": "macos-computer-use",
                    "version": "3.3.1"
                ]
            ])

        case "tools/list":
            sendResponse(id: id, result: ["tools": mcpTools])

        case "tools/call":
            guard let name = params["name"] as? String else {
                sendError(id: id, code: -32602, message: "Missing tool name")
                return
            }
            let arguments = params["arguments"] as? [String: Any] ?? [:]
            await executeTool(name: name, arguments: arguments, id: id)

        case "shutdown":
            isRunning = false
            sendResponse(id: id, result: [:])

        default:
            sendError(id: id, code: -32601, message: "Method not found: \(method)")
        }
    }

    private func executeTool(name: String, arguments: [String: Any], id: Any?) async {
        let tool = mcpTools.first { $0["name"] as? String == name }
        guard tool != nil else {
            sendError(id: id, code: -32602, message: "Unknown tool: \(name)")
            return
        }

        var args: [String] = [name]
        for (key, value) in arguments {
            let flag = "--\(key)"
            if let boolValue = value as? Bool {
                if boolValue {
                    args.append(flag)
                }
            } else {
                args.append(flag)
                args.append("\(value)")
            }
        }

        let result = await runCLICommand(args: args)
        sendResponse(id: id, result: [
            "content": [
                ["type": "text", "text": result]
            ]
        ])
    }

    private func runCLICommand(args: [String]) async -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["macos-computer-use"] + args + ["--json"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8) ?? "{}"
        } catch {
            return "{\"success\":false,\"error\":\"\(error.localizedDescription)\"}"
        }
    }

    private func sendResponse(id: Any?, result: Any) {
        var response: [String: Any] = ["jsonrpc": "2.0", "result": result]
        if let id = id { response["id"] = id }
        sendJSON(response)
    }

    private func sendError(id: Any?, code: Int, message: String) {
        var response: [String: Any] = [
            "jsonrpc": "2.0",
            "error": ["code": code, "message": message]
        ]
        if let id = id { response["id"] = id }
        sendJSON(response)
    }

    private func sendJSON(_ object: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: object),
              let json = String(data: data, encoding: .utf8) else { return }
        print(json)
        fflush(stdout)
    }

    private func log(_ message: String) {
        if logLevel == "debug" {
            fputs("[MCP] \(message)\n", stderr)
        }
    }
}

private let mcpTools: [[String: Any]] = [
    [
        "name": "screenshot",
        "description": "截取屏幕截图",
        "inputSchema": [
            "type": "object",
            "properties": [
                "outputDir": ["type": "string", "description": "输出目录"],
                "filename": ["type": "string", "description": "文件名"],
                "region": ["type": "string", "description": "区域 x,y,w,h"]
            ]
        ]
    ],
    [
        "name": "mouse-move",
        "description": "移动鼠标到指定位置",
        "inputSchema": [
            "type": "object",
            "properties": [
                "x": ["type": "integer", "description": "X 坐标"],
                "y": ["type": "integer", "description": "Y 坐标"]
            ],
            "required": ["x", "y"]
        ]
    ],
    [
        "name": "left-click",
        "description": "鼠标左键点击",
        "inputSchema": [
            "type": "object",
            "properties": [
                "x": ["type": "integer", "description": "X 坐标"],
                "y": ["type": "integer", "description": "Y 坐标"]
            ]
        ]
    ],
    [
        "name": "type",
        "description": "输入文本",
        "inputSchema": [
            "type": "object",
            "properties": [
                "text": ["type": "string", "description": "要输入的文本"]
            ],
            "required": ["text"]
        ]
    ],
    [
        "name": "key",
        "description": "按下按键",
        "inputSchema": [
            "type": "object",
            "properties": [
                "key": ["type": "string", "description": "按键名称"]
            ],
            "required": ["key"]
        ]
    ],
    [
        "name": "hotkey",
        "description": "按下快捷键",
        "inputSchema": [
            "type": "object",
            "properties": [
                "keys": ["type": "string", "description": "快捷键组合"]
            ],
            "required": ["keys"]
        ]
    ],
    [
        "name": "app-launch",
        "description": "启动应用",
        "inputSchema": [
            "type": "object",
            "properties": [
                "app": ["type": "string", "description": "应用名称"]
            ],
            "required": ["app"]
        ]
    ],
    [
        "name": "app-list",
        "description": "列出运行中的应用",
        "inputSchema": [
            "type": "object",
            "properties": [:]
        ]
    ],
    [
        "name": "frontmost-app",
        "description": "获取当前前台应用",
        "inputSchema": [
            "type": "object",
            "properties": [:]
        ]
    ],
    [
        "name": "element-find",
        "description": "查找 UI 元素",
        "inputSchema": [
            "type": "object",
            "properties": [
                "app": ["type": "string", "description": "应用名称"],
                "title": ["type": "string", "description": "元素标题"],
                "role": ["type": "string", "description": "元素角色"]
            ]
        ]
    ],
    [
        "name": "element-click",
        "description": "点击 UI 元素",
        "inputSchema": [
            "type": "object",
            "properties": [
                "app": ["type": "string", "description": "应用名称"],
                "name": ["type": "string", "description": "元素名称"]
            ],
            "required": ["app", "name"]
        ]
    ],
    [
        "name": "file-read",
        "description": "读取文件内容",
        "inputSchema": [
            "type": "object",
            "properties": [
                "path": ["type": "string", "description": "文件路径"],
                "base64": ["type": "boolean", "description": "base64 编码输出"]
            ],
            "required": ["path"]
        ]
    ],
    [
        "name": "file-write",
        "description": "写入文件",
        "inputSchema": [
            "type": "object",
            "properties": [
                "path": ["type": "string", "description": "文件路径"],
                "text": ["type": "string", "description": "文本内容"]
            ],
            "required": ["path", "text"]
        ]
    ],
    [
        "name": "browser-navigate",
        "description": "浏览器导航",
        "inputSchema": [
            "type": "object",
            "properties": [
                "url": ["type": "string", "description": "目标 URL"],
                "browser": ["type": "string", "description": "浏览器名称"]
            ],
            "required": ["url"]
        ]
    ],
    [
        "name": "browser-exec-js",
        "description": "在浏览器执行 JavaScript",
        "inputSchema": [
            "type": "object",
            "properties": [
                "script": ["type": "string", "description": "JS 代码"],
                "browser": ["type": "string", "description": "浏览器名称"]
            ],
            "required": ["script"]
        ]
    ],
    [
        "name": "pixel-color",
        "description": "读取像素颜色",
        "inputSchema": [
            "type": "object",
            "properties": [
                "x": ["type": "integer", "description": "X 坐标"],
                "y": ["type": "integer", "description": "Y 坐标"]
            ],
            "required": ["x", "y"]
        ]
    ],
    [
        "name": "notify",
        "description": "发送系统通知",
        "inputSchema": [
            "type": "object",
            "properties": [
                "title": ["type": "string", "description": "通知标题"],
                "message": ["type": "string", "description": "通知内容"]
            ],
            "required": ["title"]
        ]
    ]
]
