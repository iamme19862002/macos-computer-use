//
//  ElementClickCommand.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import ArgumentParser
import ApplicationServices

struct ElementClickCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "element-click",
        abstract: "点击 UI 元素，支持系统对话框 (Sheet) 内的元素，自动聚焦应用"
    )

    @Option(name: .long, help: "按角色查找")
    var role: String?

    @Option(name: .long, help: "按标题查找（只匹配 title 属性）")
    var title: String?

    @Option(name: .long, help: "按标识符查找")
    var identifier: String?

    @Option(name: .long, help: "按描述查找（只匹配 description 属性）")
    var description: String?

    @Option(name: .long, help: "按标签模糊查找（同时匹配 title、value、description）")
    var label: String?

    @Option(name: .long, help: "在指定应用中查找（会自动激活应用）")
    var app: String?

    @Flag(name: .long, help: "在系统对话框 (Sheet) 中查找")
    var sheet = false

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        // 如果指定了应用，先激活应用
        if let appName = app {
            let activateResult = AppManager.activate(appName: appName)
            if !activateResult.success {
                if json {
                    print("""
                    {
                      "success": false,
                      "message": "Failed to activate app: \(appName)"
                    }
                    """)
                } else {
                    print("✗ Failed to activate app: \(appName)")
                }
                return
            }
            // 等待应用完全激活
            try await Task.sleep(nanoseconds: 500_000_000)
        }

        let results: [(element: AXUIElement, info: UIElementInfo)]
        
        if sheet, let appName = app {
            // Search in sheet elements - 使用与 AccessibilityManager.findElements 一致的匹配逻辑
            let sheets = AccessibilityManager.findSheetElements(inApp: appName)
            var sheetResults: [(AXUIElement, UIElementInfo)] = []
            
            for sheetElement in sheets {
                let found = searchElementsInSheet(
                    sheetElement,
                    byRole: role,
                    byTitle: title,
                    byIdentifier: identifier,
                    byDescription: description,
                    byLabel: label
                )
                sheetResults.append(contentsOf: found)
            }
            results = sheetResults
        } else {
            // 统一使用 AccessibilityManager.findElements，享受相同的匹配逻辑
            results = AccessibilityManager.findElements(
                byRole: role,
                byTitle: title,
                byIdentifier: identifier,
                byDescription: description,
                byLabel: label,
                inApp: app
            )
        }

        guard let first = results.first else {
            if json {
                print("""
                {
                  "success": false,
                  "message": "Element not found"
                }
                """)
            } else {
                print("✗ Element not found")
            }
            return
        }

        let success = AccessibilityManager.clickElement(first.element)
        let info = first.info

        if json {
            print("""
            {
              "success": \(success),
              "element": {
                "role": "\(info.role)",
                "title": "\(info.title)",
                "bounds": {
                  "x": \(info.bounds.x),
                  "y": \(info.bounds.y),
                  "width": \(info.bounds.width),
                  "height": \(info.bounds.height)
                }
              }
            }
            """)
        } else {
            if success {
                print("✓ Clicked \(info.role): \(info.title)")
            } else {
                print("✗ Failed to click \(info.role): \(info.title)")
            }
        }
    }
    
    private func searchElementsInSheet(
        _ element: AXUIElement,
        byRole: String?,
        byTitle: String?,
        byIdentifier: String?,
        byDescription: String?,
        byLabel: String?
    ) -> [(AXUIElement, UIElementInfo)] {
        var results: [(AXUIElement, UIElementInfo)] = []
        
        if let info = AccessibilityManager.getElementInfo(element) {
            var match = true
            
            if let role = byRole, !info.role.lowercased().contains(role.lowercased()) {
                match = false
            }
            // --title 只匹配 title 属性
            if let title = byTitle, !info.title.lowercased().contains(title.lowercased()) {
                match = false
            }
            if let identifier = byIdentifier, info.identifier?.lowercased().contains(identifier.lowercased()) != true {
                match = false
            }
            // --description 只匹配 description 属性
            if let description = byDescription, info.description?.lowercased().contains(description.lowercased()) != true {
                match = false
            }
            // --label 模糊匹配：同时匹配 title、value、description
            if let label = byLabel {
                let searchLabel = label.lowercased()
                let infoTitle = info.title.lowercased()
                let infoValue = info.value?.lowercased() ?? ""
                let infoDescription = info.description?.lowercased() ?? ""
                
                let isMatch = infoTitle.contains(searchLabel) || 
                             infoValue.contains(searchLabel) || 
                             infoDescription.contains(searchLabel)
                if !isMatch {
                    match = false
                }
            }
            
            if match {
                results.append((element, info))
            }
        }
        
        // Search children
        var children: CFTypeRef?
        let childResult = AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &children)
        
        if childResult == .success, let childArray = children as? [AXUIElement] {
            for child in childArray {
                let childResults = searchElementsInSheet(
                    child, 
                    byRole: byRole, 
                    byTitle: byTitle, 
                    byIdentifier: byIdentifier,
                    byDescription: byDescription,
                    byLabel: byLabel
                )
                results.append(contentsOf: childResults)
            }
        }
        
        return results
    }
}
