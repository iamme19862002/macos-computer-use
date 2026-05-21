//
//  main.swift
//  macos-computer-use
//
//  Created by iamme19862002 on 2025.
//  Copyright (c) 2025 iamme19862002. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

@main
struct MacOSComputerUse: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "macos-computer-use",
        abstract: "macOS 通用计算机控制 CLI - 零 token 开销的 computer-use 工具",
        version: "1.0.0",
        subcommands: [
            ScreenshotCommand.self,
            CursorPositionCommand.self,
            MouseMoveCommand.self,
            LeftClickCommand.self,
            RightClickCommand.self,
            MiddleClickCommand.self,
            DoubleClickCommand.self,
            DragCommand.self,
            ScrollCommand.self,
            KeyCommand.self,
            TypeCommand.self,
        ]
    )
}
