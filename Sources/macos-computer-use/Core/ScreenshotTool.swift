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
    
    static func findWindowId(forApp appName: String) -> UInt32? {
        let windowList = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []
        let lowercased = appName.lowercased()
        
        for window in windowList {
            guard let ownerName = window[kCGWindowOwnerName as String] as? String,
                  let windowId = window[kCGWindowNumber as String] as? UInt32 else {
                continue
            }
            
            if ownerName.lowercased() == lowercased || ownerName.lowercased().contains(lowercased) {
                return windowId
            }
        }
        return nil
    }
    
    /// 查找应用的所有窗口（包括主窗口和 Sheet/对话框）
    static func findAllWindows(forApp appName: String) -> [(windowId: UInt32, bounds: CGRect)] {
        let windowList = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []
        let lowercased = appName.lowercased()
        var result: [(UInt32, CGRect)] = []
        
        for window in windowList {
            guard let ownerName = window[kCGWindowOwnerName as String] as? String,
                  let windowId = window[kCGWindowNumber as String] as? UInt32,
                  let bounds = window[kCGWindowBounds as String] as? [String: CGFloat],
                  let x = bounds["X"],
                  let y = bounds["Y"],
                  let width = bounds["Width"],
                  let height = bounds["Height"] else {
                continue
            }
            
            if ownerName.lowercased() == lowercased || ownerName.lowercased().contains(lowercased) {
                let rect = CGRect(x: x, y: y, width: width, height: height)
                result.append((windowId, rect))
            }
        }
        return result
    }
    
    /// 计算多个窗口的并集区域
    static func unionBounds(_ windows: [(windowId: UInt32, bounds: CGRect)]) -> CGRect? {
        guard !windows.isEmpty else { return nil }
        
        var unionRect = windows[0].bounds
        for i in 1..<windows.count {
            unionRect = unionRect.union(windows[i].bounds)
        }
        return unionRect
    }

    /// 截图并保存，返回 file:// URL
    static func capture(
        outputDir: String? = nil,
        filename: String? = nil,
        region: String? = nil,
        windowId: UInt32? = nil,
        appName: String? = nil,
        markElements: Bool = false
    ) -> ScreenshotResult {
        // 1. 获取光标位置
        let cursorPos = MouseController.currentPosition()

        // 2. 捕获屏幕（多策略回退）
        var image: CGImage?
        
        if let appName = appName {
            // 应用级截图：截取应用的所有窗口（包括主窗口和 Sheet/对话框）
            image = captureAppWindows(appName: appName)
        } else {
            image = captureScreen(region: region, windowId: windowId) ?? captureWithScreencapture(region: region, windowId: windowId)
        }
        
        guard var image = image else {
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

    /// 截取应用的所有窗口（包括主窗口和 Sheet/对话框）
    /// 使用 screencapture -l 命令，它会自动包含附加到主窗口的 Sheet/对话框
    private static func captureAppWindows(appName: String) -> CGImage? {
        // 1. 获取应用的主窗口（最底层的窗口）
        let windows = findAllWindows(forApp: appName)
        guard !windows.isEmpty else { return nil }
        
        // 找到最底层的窗口（Y 坐标最大 + 高度最大的通常是主窗口）
        let mainWindow = windows.max { a, b in
            let aBottom = a.bounds.origin.y + a.bounds.height
            let bBottom = b.bounds.origin.y + b.bounds.height
            return aBottom < bBottom
        }
        
        guard let mainWindowId = mainWindow?.windowId else { return nil }
        
        // 2. 使用 screencapture -l 截取主窗口及其附加的 Sheet/对话框
        // 增加重试机制（最多3次），处理窗口状态变化导致的截图失败
        var lastError: String?
        for attempt in 1...3 {
            if let image = captureWithScreencapture(windowId: mainWindowId) {
                return image
            }
            
            // 获取更详细的错误信息
            let tmpPath = "/tmp/mcu_retry_\(UUID().uuidString).png"
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
            process.arguments = ["-x", "-C", "-l", String(mainWindowId), tmpPath]
            
            let pipe = Pipe()
            process.standardError = pipe
            
            do {
                try process.run()
                process.waitUntilExit()
                if process.terminationStatus != 0 {
                    let errorData = pipe.fileHandleForReading.readDataToEndOfFile()
                    lastError = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            } catch {
                lastError = error.localizedDescription
            }
            
            // 等待一小段时间让窗口状态稳定
            if attempt < 3 {
                Thread.sleep(forTimeInterval: 0.5)
            }
        }
        
        // 3. 如果 screencapture 多次失败，回退到全屏截图+裁剪
        if let unionBounds = unionBounds(windows), !unionBounds.isEmpty {
            let region = "\(Int(unionBounds.origin.x)),\(Int(unionBounds.origin.y)),\(Int(unionBounds.width)),\(Int(unionBounds.height))"
            if let fallbackImage = captureWithScreencapture(region: region) {
                return fallbackImage
            }
        }
        
        // 4. 最后回退到全屏截图
        let errorMsg = lastError ?? "could not create image from window"
        print("Screenshot retry failed: \(errorMsg), falling back to full screen capture")
        return captureWithScreencapture()
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
            // 使用 -l 参数截取指定窗口及其附加的 Sheet/对话框
            args.append("-l")
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
