//
//  ScreenshotTool.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
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
    static func capture(
        outputDir: String? = nil,
        filename: String? = nil,
        region: String? = nil,
        windowId: UInt32? = nil,
        markElements: Bool = false
    ) -> ScreenshotResult {
        // 1. 获取光标位置
        let cursorPos = MouseController.currentPosition()

        // 2. 捕获屏幕（多策略回退）
        guard var image = captureScreen(region: region, windowId: windowId) ?? captureWithScreencapture(region: region, windowId: windowId) else {
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

        // 3. 标记 UI 元素（如果启用）
        if markElements {
            image = drawElements(on: image)
        }

        // 4. 绘制十字准星
        let imageWithCrosshair = drawCrosshair(on: image, at: cursorPos)

        // 5. 保存文件
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

        // 6. 获取文件大小
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

    private static func captureScreen(region: String? = nil, windowId: UInt32? = nil) -> CGImage? {
        if let windowId = windowId {
            // 截取指定窗口
            return CGWindowListCreateImage(
                .null,
                .optionIncludingWindow,
                CGWindowID(windowId),
                [.boundsIgnoreFraming]
            )
        }

        if let region = region {
            // 截取指定区域
            let parts = region.split(separator: ",").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
            guard parts.count == 4 else { return nil }
            let rect = CGRect(x: parts[0], y: parts[1], width: parts[2], height: parts[3])
            let displayID = CGMainDisplayID()
            guard let image = CGDisplayCreateImage(displayID) else { return nil }
            return image.cropping(to: rect)
        }

        // 全屏截图
        let displayID = CGMainDisplayID()
        return CGDisplayCreateImage(displayID)
    }

    private static func captureWithScreencapture(region: String? = nil, windowId: UInt32? = nil) -> CGImage? {
        let tmpPath = "/tmp/mcu_\(UUID().uuidString).png"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")

        var args = ["-x", "-C"]
        if let windowId = windowId {
            args.append("-w")
            args.append(String(windowId))
        } else if let region = region {
            args.append("-R")
            args.append(region)
        }
        args.append(tmpPath)

        process.arguments = args
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

    private static func drawElements(on image: CGImage) -> CGImage {
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

        // 获取所有窗口并绘制边框
        let windowList = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []

        for window in windowList {
            guard let bounds = window[kCGWindowBounds as String] as? [String: CGFloat],
                  let x = bounds["X"],
                  let y = bounds["Y"],
                  let width = bounds["Width"],
                  let height = bounds["Height"],
                  let name = window[kCGWindowOwnerName as String] as? String else {
                continue
            }

            // 跳过系统窗口
            if name.contains("WindowManager") || name.contains("Dock") || name.contains("menubar") {
                continue
            }

            let rect = CGRect(x: x, y: size.height - y - height, width: width, height: height)

            // 绘制半透明填充
            context.setFillColor(red: 0, green: 1, blue: 0, alpha: 0.1)
            context.fill(rect)

            // 绘制边框
            context.setStrokeColor(red: 0, green: 1, blue: 0, alpha: 0.8)
            context.setLineWidth(2)
            context.stroke(rect)

            // 绘制标签
            let label = name as NSString
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 12),
                .foregroundColor: NSColor.white
            ]
            let textSize = label.size(withAttributes: attributes)
            let textRect = CGRect(x: rect.minX, y: rect.maxY - textSize.height, width: textSize.width + 8, height: textSize.height + 4)

            context.setFillColor(red: 0, green: 0.5, blue: 0, alpha: 0.8)
            context.fill(textRect)

            // 需要在 NSGraphicsContext 中绘制文字，这里简化处理
        }

        return context.makeImage() ?? image
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
