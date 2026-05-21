//
//  ScreenshotTool.swift
//  macos-computer-use
//
//  Created by iamme19862002 on 2025.
//  Copyright (c) 2025 iamme19862002. All rights reserved.
//  Licensed under the MIT License.
//

import CoreGraphics
import AppKit
import Foundation
import UniformTypeIdentifiers

struct ScreenshotResult {
    let success: Bool
    let url: String
    let filepath: String
    let filename: String
    let sizeBytes: Int
    let imageWidth: Int
    let imageHeight: Int
    let cursorPosition: CursorPosition
    let error: String?

    var jsonString: String {
        if success {
            return """
            {
              "success": true,
              "url": "\(url)",
              "filepath": "\(filepath)",
              "filename": "\(filename)",
              "size_bytes": \(sizeBytes),
              "image_width": \(imageWidth),
              "image_height": \(imageHeight),
              "cursor_position": {"x": \(cursorPosition.x), "y": \(cursorPosition.y)}
            }
            """
        } else {
            return """
            {
              "success": false,
              "error": "\(error ?? "Unknown error")"
            }
            """
        }
    }
}

struct CursorPosition {
    let x: Int
    let y: Int
}

struct ScreenshotTool {
    static let screenshotDir = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".macos_computer_use/screenshots")

    /// 截图并保存，返回 file:// URL
    static func capture(outputDir: String? = nil, filename: String? = nil) -> ScreenshotResult {
        // 1. 获取光标位置
        let cursorPos = MouseController.currentPosition()

        // 2. 捕获屏幕（多策略回退）
        guard let image = captureScreen() ?? captureWithScreencapture() else {
            return ScreenshotResult(
                success: false,
                url: "",
                filepath: "",
                filename: "",
                sizeBytes: 0,
                imageWidth: 0,
                imageHeight: 0,
                cursorPosition: CursorPosition(x: Int(cursorPos.x), y: Int(cursorPos.y)),
                error: "Failed to capture screen"
            )
        }

        // 3. 绘制十字准星
        let imageWithCrosshair = drawCrosshair(on: image, at: cursorPos)

        // 4. 保存文件
        let dir = outputDir.map { URL(fileURLWithPath: $0) } ?? screenshotDir
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let name = filename ?? "screenshot_\(Int(Date().timeIntervalSince1970)).png"
        let fileURL = dir.appendingPathComponent(name)
        let filepath = fileURL.path

        guard let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, UTType.png.identifier as CFString, 1, nil) else {
            return ScreenshotResult(
                success: false,
                url: "",
                filepath: "",
                filename: "",
                sizeBytes: 0,
                imageWidth: imageWithCrosshair.width,
                imageHeight: imageWithCrosshair.height,
                cursorPosition: CursorPosition(x: Int(cursorPos.x), y: Int(cursorPos.y)),
                error: "Failed to create image destination"
            )
        }

        CGImageDestinationAddImage(destination, imageWithCrosshair, nil)
        guard CGImageDestinationFinalize(destination) else {
            return ScreenshotResult(
                success: false,
                url: "",
                filepath: "",
                filename: "",
                sizeBytes: 0,
                imageWidth: imageWithCrosshair.width,
                imageHeight: imageWithCrosshair.height,
                cursorPosition: CursorPosition(x: Int(cursorPos.x), y: Int(cursorPos.y)),
                error: "Failed to write image"
            )
        }

        // 5. 获取文件大小
        let fileSize = (try? FileManager.default.attributesOfItem(atPath: filepath)[.size] as? Int) ?? 0
        let url = fileURL.absoluteString

        return ScreenshotResult(
            success: true,
            url: url,
            filepath: filepath,
            filename: name,
            sizeBytes: fileSize,
            imageWidth: imageWithCrosshair.width,
            imageHeight: imageWithCrosshair.height,
            cursorPosition: CursorPosition(x: Int(cursorPos.x), y: Int(cursorPos.y)),
            error: nil
        )
    }

    private static func captureScreen() -> CGImage? {
        // 策略1: CGDisplayCreateImage（全屏，无闪屏）
        let displayID = CGMainDisplayID()
        return CGDisplayCreateImage(displayID)
    }

    private static func captureWithScreencapture() -> CGImage? {
        // 策略2: screencapture 命令（最可靠）
        let tmpPath = "/tmp/mcu_\(UUID().uuidString).png"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        process.arguments = ["-x", "-C", tmpPath]
        try? process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0,
              let data = FileManager.default.contents(atPath: tmpPath),
              let image = NSImage(data: data),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            try? FileManager.default.removeItem(atPath: tmpPath)
            return nil
        }
        try? FileManager.default.removeItem(atPath: tmpPath)
        return cgImage
    }

    private static func drawCrosshair(on image: CGImage, at position: CGPoint) -> CGImage {
        let size = CGSize(width: image.width, height: image.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return image
        }

        // 绘制原图
        context.draw(image, in: CGRect(origin: .zero, size: size))

        // 绘制十字准星
        let crosshairSize: CGFloat = 20
        let lineWidth: CGFloat = 3
        context.setStrokeColor(red: 1, green: 0, blue: 0, alpha: 1)
        context.setLineWidth(lineWidth)

        // 水平线
        context.move(to: CGPoint(x: position.x - crosshairSize, y: position.y))
        context.addLine(to: CGPoint(x: position.x + crosshairSize, y: position.y))

        // 垂直线
        context.move(to: CGPoint(x: position.x, y: position.y - crosshairSize))
        context.addLine(to: CGPoint(x: position.x, y: position.y + crosshairSize))

        context.strokePath()

        return context.makeImage() ?? image
    }
}
