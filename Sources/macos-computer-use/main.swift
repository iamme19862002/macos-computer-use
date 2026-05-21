//
//  main.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation

@main
struct MacOSComputerUse: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "macos-computer-use",
        abstract: "macOS 通用计算机控制 CLI - 零 token 开销的 computer-use 工具",
        version: "2.0.0",
        subcommands: [
            // 截图
            ScreenshotCommand.self,
            // 鼠标
            CursorPositionCommand.self,
            MouseMoveCommand.self,
            LeftClickCommand.self,
            RightClickCommand.self,
            MiddleClickCommand.self,
            DoubleClickCommand.self,
            DragCommand.self,
            ScrollCommand.self,
            // 键盘
            KeyCommand.self,
            TypeCommand.self,
            // 应用管理
            AppLaunchCommand.self,
            AppQuitCommand.self,
            AppListCommand.self,
            AppActivateCommand.self,
            AppHideCommand.self,
            // 窗口管理
            WindowListCommand.self,
            WindowResizeCommand.self,
            WindowMoveCommand.self,
            WindowMinimizeCommand.self,
            WindowCloseCommand.self,
            WindowFocusCommand.self,
            // UI 元素
            ElementFindCommand.self,
            ElementClickCommand.self,
            ElementInfoCommand.self,
            ElementListCommand.self,
        ]
    )
}
