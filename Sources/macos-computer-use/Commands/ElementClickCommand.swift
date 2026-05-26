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

    @Option(name: .long, help: "按标题查找")
    var title: String?

    @Option(name: .long, help: "按标识符查找")
    var identifier: String?

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
            // Search in sheet elements
            let sheets = AccessibilityManager.findSheetElements(inApp: appName)
            var sheetResults: [(AXUIElement, UIElementInfo)] = []
            
            for sheetElement in sheets {
                let found = searchInElement(
                    sheetElement,
                    byRole: role,
                    byTitle: title,
                    byIdentifier: identifier
                )
                sheetResults.append(contentsOf: found)
            }
            results = sheetResults
        } else {
            results = AccessibilityManager.findElements(
                byRole: role,
                byTitle: title,
                byIdentifier: identifier,
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
    
    private func searchInElement(
        _ element: AXUIElement,
        byRole: String?,
        byTitle: String?,
        byIdentifier: String?
    ) -> [(AXUIElement, UIElementInfo)] {
        var results: [(AXUIElement, UIElementInfo)] = []
        
        if let info = AccessibilityManager.getElementInfo(element) {
            var match = true
            
            if let role = byRole, !info.role.lowercased().contains(role.lowercased()) {
                match = false
            }
            if let title = byTitle {
                let isMatch = info.title.range(of: title, options: .caseInsensitive) != nil
                if !isMatch {
                    match = false
                }
            }
            if let identifier = byIdentifier, info.identifier?.lowercased().contains(identifier.lowercased()) != true {
                match = false
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
                let childResults = searchInElement(child, byRole: byRole, byTitle: byTitle, byIdentifier: byIdentifier)
                results.append(contentsOf: childResults)
            }
        }
        
        return results
    }
}
