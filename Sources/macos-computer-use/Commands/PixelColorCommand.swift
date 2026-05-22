//
//  PixelColorCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation
import CoreGraphics

struct PixelColorCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "pixel-color",
        abstract: "读取指定坐标的像素颜色"
    )

    @Option(name: .shortAndLong, help: "X 坐标")
    var x: Int

    @Option(name: .shortAndLong, help: "Y 坐标")
    var y: Int

    @Option(name: .long, help: "显示器索引（默认主显示器）")
    var display: UInt32?

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() throws {
        let displayID = display.map { CGDirectDisplayID($0) } ?? CGMainDisplayID()
        guard let image = CGDisplayCreateImage(displayID) else {
            if json {
                printJSON(["success": false, "error": "无法捕获屏幕"])
            } else {
                print("✗ 无法捕获屏幕")
            }
            throw ExitCode.failure
        }

        let width = image.width
        let height = image.height

        guard x >= 0, x < width, y >= 0, y < height else {
            if json {
                printJSON([
                    "success": false,
                    "error": "坐标超出屏幕范围",
                    "screenWidth": width,
                    "screenHeight": height,
                    "x": x,
                    "y": y
                ])
            } else {
                print("✗ 坐标超出屏幕范围: (\(x), \(y)), 屏幕尺寸: (\(width)x\(height))")
            }
            throw ExitCode.failure
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)

        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            if json {
                printJSON(["success": false, "error": "无法创建像素上下文"])
            } else {
                print("✗ 无法创建像素上下文")
            }
            throw ExitCode.failure
        }

        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

        let idx = ((height - y - 1) * width + x) * 4
        let r = pixels[idx]
        let g = pixels[idx + 1]
        let b = pixels[idx + 2]
        let a = pixels[idx + 3]

        let hex = String(format: "#%02X%02X%02X", r, g, b)
        let rgba = "rgba(\(r), \(g), \(b), \(a))"

        if json {
            printJSON([
                "success": true,
                "x": x,
                "y": y,
                "hex": hex,
                "rgba": rgba,
                "r": r,
                "g": g,
                "b": b,
                "a": a
            ])
        } else {
            print("Color at (\(x), \(y)): \(hex) / \(rgba)")
        }
    }
}
