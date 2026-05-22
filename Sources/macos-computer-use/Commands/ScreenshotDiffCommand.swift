//
//  ScreenshotDiffCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import Foundation
import CoreGraphics
import AppKit
import UniformTypeIdentifiers

struct ScreenshotDiffCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "screenshot-diff",
        abstract: "对比两张截图的差异"
    )

    @Argument(help: "第一张截图路径")
    var image1: String

    @Argument(help: "第二张截图路径")
    var image2: String

    @Option(name: .long, help: "差异输出路径")
    var output: String?

    @Option(name: .long, help: "像素差异阈值（0-255，默认30）")
    var threshold: Int = 30

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() throws {
        let expanded1 = NSString(string: image1).expandingTildeInPath
        let expanded2 = NSString(string: image2).expandingTildeInPath

        guard let img1 = loadImage(path: expanded1),
              let img2 = loadImage(path: expanded2) else {
            if json {
                printJSON(["success": false, "error": "无法加载图片"])
            } else {
                print("✗ 无法加载图片")
            }
            throw ExitCode.failure
        }

        let w1 = img1.width
        let h1 = img1.height
        let w2 = img2.width
        let h2 = img2.height

        if w1 != w2 || h1 != h2 {
            if json {
                printJSON([
                    "success": false,
                    "error": "图片尺寸不一致",
                    "size1": ["width": w1, "height": h1],
                    "size2": ["width": w2, "height": h2]
                ])
            } else {
                print("✗ 图片尺寸不一致: (\(w1)x\(h1)) vs (\(w2)x\(h2))")
            }
            throw ExitCode.failure
        }

        guard let data1 = pixelData(from: img1),
              let data2 = pixelData(from: img2) else {
            if json {
                printJSON(["success": false, "error": "无法读取像素数据"])
            } else {
                print("✗ 无法读取像素数据")
            }
            throw ExitCode.failure
        }

        var diffCount = 0
        let totalPixels = w1 * h1
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let diffContext = CGContext(
            data: nil,
            width: w1,
            height: h1,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            if json {
                printJSON(["success": false, "error": "无法创建差异图像"])
            } else {
                print("✗ 无法创建差异图像")
            }
            throw ExitCode.failure
        }

        diffContext.draw(img1, in: CGRect(x: 0, y: 0, width: w1, height: h1))

        for y in 0..<h1 {
            for x in 0..<w1 {
                let idx = (y * w1 + x) * 4
                let r1 = Int(data1[idx])
                let g1 = Int(data1[idx + 1])
                let b1 = Int(data1[idx + 2])
                let r2 = Int(data2[idx])
                let g2 = Int(data2[idx + 1])
                let b2 = Int(data2[idx + 2])

                let diff = abs(r1 - r2) + abs(g1 - g2) + abs(b1 - b2)
                if diff > threshold * 3 {
                    diffCount += 1
                    diffContext.setFillColor(red: 1, green: 0, blue: 0, alpha: 0.8)
                    diffContext.fill(CGRect(x: x, y: h1 - y - 1, width: 1, height: 1))
                }
            }
        }

        let diffPercent = Double(diffCount) / Double(totalPixels) * 100

        if let outputPath = output {
            let expandedOutput = NSString(string: outputPath).expandingTildeInPath
            if let diffImage = diffContext.makeImage(),
               let dest = CGImageDestinationCreateWithURL(
                URL(fileURLWithPath: expandedOutput) as CFURL,
                UTType.png.identifier as CFString, 1, nil) {
                CGImageDestinationAddImage(dest, diffImage, nil)
                CGImageDestinationFinalize(dest)
            }
        }

        if json {
            printJSON([
                "success": true,
                "diffPixels": diffCount,
                "totalPixels": totalPixels,
                "diffPercent": String(format: "%.2f", diffPercent),
                "threshold": threshold,
                "hasDiff": diffCount > 0,
                "output": output ?? ""
            ])
        } else {
            if diffCount > 0 {
                print("⚠️  发现 \(diffCount) 个差异像素 (\(String(format: "%.2f", diffPercent))%)")
                if let out = output {
                    print("差异图已保存至: \(out)")
                }
            } else {
                print("✓ 两张截图完全一致")
            }
        }
    }

    private func loadImage(path: String) -> CGImage? {
        guard let data = FileManager.default.contents(atPath: path),
              let image = NSImage(data: data) else { return nil }
        return image.cgImage(forProposedRect: nil, context: nil, hints: nil)
    }

    private func pixelData(from image: CGImage) -> [UInt8]? {
        let width = image.width
        let height = image.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)

        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return pixels
    }
}
