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
        version: "3.3.0",
        subcommands: [
            // 截图
            ScreenshotCommand.self,
            ScreenshotDiffCommand.self,
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
            HotkeyCommand.self,
            KeySequenceCommand.self,
            TypeCommand.self,
            // 应用管理
            AppLaunchCommand.self,
            AppQuitCommand.self,
            AppListCommand.self,
            AppActivateCommand.self,
            AppHideCommand.self,
            FrontmostAppCommand.self,
            // 窗口管理
            WindowListCommand.self,
            WindowResizeCommand.self,
            WindowMoveCommand.self,
            WindowMinimizeCommand.self,
            WindowMaximizeCommand.self,
            WindowCloseCommand.self,
            WindowFocusCommand.self,
            // 鼠标增强
            MouseHoverCommand.self,
            // UI 元素
            ElementFindCommand.self,
            ElementClickCommand.self,
            ElementInfoCommand.self,
            ElementListCommand.self,
            FocusedElementCommand.self,
            ScrollToElementCommand.self,
            // 等待机制
            WaitForElementCommand.self,
            WaitForAppCommand.self,
            SleepCommand.self,
            // 断言
            AssertElementExistsCommand.self,
            AssertTextExistsCommand.self,
            AssertElementPropertyCommand.self,
            AssertClipboardCommand.self,
            // 重试
            RetryCommand.self,
            // 测试报告
            TestStartCommand.self,
            TestEndCommand.self,
            StepCommand.self,
            // 剪贴板
            ClipboardCopyCommand.self,
            ClipboardPasteCommand.self,
            ClipboardGetCommand.self,
            // 系统信息
            ScreenInfoCommand.self,
            DisplayListCommand.self,
            SystemInfoCommand2.self,
            // 进程管理
            ProcessListCommand.self,
            ProcessKillCommand.self,
            // 录制回放
            RecordCommand.self,
            ReplayCommand.self,
            // 脚本执行
            RunScriptCommand.self,
            // OCR
            OCRCommand.self,
            // 视觉定位
            FindImageCommand.self,
            ClickImageCommand.self,
            // 像素颜色
            PixelColorCommand.self,
            // 文本选择
            TextSelectCommand.self,
            // 菜单操作
            MenuClickCommand.self,
            // 通知
            NotifyCommand.self,
            // 文件系统
            FileReadCommand.self,
            FileWriteCommand.self,
            FileExistsCommand.self,
            DirListCommand.self,
            // 浏览器控制
            BrowserNavigateCommand.self,
            BrowserGetUrlCommand.self,
            BrowserExecJsCommand.self,
            BrowserNewTabCommand.self,
            BrowserCloseTabCommand.self,
            // AppleScript 桥接
            OsascriptCommand.self,
            // 弹窗处理
            DialogDetectCommand.self,
            DialogDismissCommand.self,
            // 文件对话框
            DialogOpenCommand.self,
            DialogSaveCommand.self,
        ]
    )
}
