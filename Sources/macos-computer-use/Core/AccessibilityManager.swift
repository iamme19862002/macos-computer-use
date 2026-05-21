//
//  AccessibilityManager.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import AppKit
import CoreGraphics
import Foundation

struct UIElementInfo: Codable {
    let role: String
    let title: String
    let value: String?
    let bounds: WindowBounds
    let identifier: String?
    let description: String?
    let isEnabled: Bool
    let isFocused: Bool
    var children: [UIElementInfo]?
}

struct AccessibilityManager {
    
    static func findElements(
        byRole: String? = nil,
        byTitle: String? = nil,
        byIdentifier: String? = nil,
        byDescription: String? = nil,
        inApp: String? = nil
    ) -> [(element: AXUIElement, info: UIElementInfo)] {
        var results: [(AXUIElement, UIElementInfo)] = []
        
        let apps: [AXUIElement]
        if let appName = inApp {
            apps = findAppElements(named: appName)
        } else {
            apps = getAllAppElements()
        }
        
        for app in apps {
            let found = searchElements(
                in: app,
                byRole: byRole,
                byTitle: byTitle,
                byIdentifier: byIdentifier,
                byDescription: byDescription
            )
            results.append(contentsOf: found)
        }
        
        return results
    }
    
    static func getElementInfo(_ element: AXUIElement) -> UIElementInfo? {
        let role = getAttribute(element, kAXRoleAttribute) as? String ?? "Unknown"
        let title = getAttribute(element, kAXTitleAttribute) as? String ?? ""
        let value = getAttribute(element, kAXValueAttribute) as? String
        let identifier = getAttribute(element, kAXIdentifierAttribute) as? String
        let description = getAttribute(element, kAXDescriptionAttribute) as? String
        let isEnabled = getAttribute(element, kAXEnabledAttribute) as? Bool ?? false
        let isFocused = getAttribute(element, kAXFocusedAttribute) as? Bool ?? false
        
        let bounds = getElementBounds(element)
        
        return UIElementInfo(
            role: role,
            title: title,
            value: value,
            bounds: bounds,
            identifier: identifier,
            description: description,
            isEnabled: isEnabled,
            isFocused: isFocused,
            children: nil
        )
    }
    
    static func clickElement(_ element: AXUIElement) -> Bool {
        let result = AXUIElementPerformAction(element, kAXPressAction as CFString)
        return result == .success
    }
    
    static func getElementBounds(_ element: AXUIElement) -> WindowBounds {
        var positionValue: CFTypeRef?
        var sizeValue: CFTypeRef?
        
        AXUIElementCopyAttributeValue(element, kAXPositionAttribute as CFString, &positionValue)
        AXUIElementCopyAttributeValue(element, kAXSizeAttribute as CFString, &sizeValue)
        
        var position = CGPoint.zero
        var size = CGSize.zero
        
        if let pos = positionValue {
            AXValueGetValue(pos as! AXValue, .cgPoint, &position)
        }
        if let sz = sizeValue {
            AXValueGetValue(sz as! AXValue, .cgSize, &size)
        }
        
        return WindowBounds(
            x: Double(position.x),
            y: Double(position.y),
            width: Double(size.width),
            height: Double(size.height)
        )
    }
    
    static func getElementTree(inApp: String? = nil, maxDepth: Int = 3) -> [UIElementInfo] {
        let apps: [AXUIElement]
        if let appName = inApp {
            apps = findAppElements(named: appName)
        } else {
            apps = getAllAppElements()
        }
        
        return apps.compactMap { buildElementTree($0, depth: 0, maxDepth: maxDepth) }
    }
    
    static func getFocusedElement() -> (element: AXUIElement, info: UIElementInfo)? {
        let systemWide = AXUIElementCreateSystemWide()
        var focused: CFTypeRef?
        
        let result = AXUIElementCopyAttributeValue(systemWide, kAXFocusedUIElementAttribute as CFString, &focused)
        
        guard result == .success, let element = focused else { return nil }
        
        let axElement = element as! AXUIElement
        guard let info = getElementInfo(axElement) else { return nil }
        
        return (axElement, info)
    }
    
    static func setFocus(_ element: AXUIElement) -> Bool {
        let result = AXUIElementSetAttributeValue(element, kAXFocusedAttribute as CFString, true as CFTypeRef)
        return result == .success
    }
    
    static func getElementAtPosition(x: CGFloat, y: CGFloat) -> (element: AXUIElement, info: UIElementInfo)? {
        let systemWide = AXUIElementCreateSystemWide()
        var element: AXUIElement?
        
        let result = AXUIElementCopyElementAtPosition(systemWide, Float(x), Float(y), &element)
        
        guard result == .success, let el = element else { return nil }
        guard let info = getElementInfo(el) else { return nil }
        
        return (el, info)
    }
    
    private static func getAllAppElements() -> [AXUIElement] {
        let workspace = NSWorkspace.shared
        return workspace.runningApplications.compactMap { app in
            return AXUIElementCreateApplication(app.processIdentifier)
        }
    }
    
    private static func findAppElements(named: String) -> [AXUIElement] {
        let workspace = NSWorkspace.shared
        let apps = workspace.runningApplications.filter { app in
            let nameMatch = app.localizedName?.lowercased().contains(named.lowercased()) ?? false
            let bundleMatch = app.bundleIdentifier?.lowercased().contains(named.lowercased()) ?? false
            return nameMatch || bundleMatch
        }
        return apps.map { AXUIElementCreateApplication($0.processIdentifier) }
    }
    
    private static func searchElements(
        in element: AXUIElement,
        byRole: String?,
        byTitle: String?,
        byIdentifier: String?,
        byDescription: String?
    ) -> [(AXUIElement, UIElementInfo)] {
        var results: [(AXUIElement, UIElementInfo)] = []
        
        if let info = getElementInfo(element) {
            var match = true
            
            if let role = byRole, !info.role.lowercased().contains(role.lowercased()) {
                match = false
            }
            if let title = byTitle, !info.title.lowercased().contains(title.lowercased()) {
                match = false
            }
            if let identifier = byIdentifier, info.identifier?.lowercased().contains(identifier.lowercased()) != true {
                match = false
            }
            if let description = byDescription, info.description?.lowercased().contains(description.lowercased()) != true {
                match = false
            }
            
            if match {
                results.append((element, info))
            }
        }
        
        var children: CFTypeRef?
        let childResult = AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &children)
        
        if childResult == .success, let childArray = children as? [AXUIElement] {
            for child in childArray {
                let childResults = searchElements(
                    in: child,
                    byRole: byRole,
                    byTitle: byTitle,
                    byIdentifier: byIdentifier,
                    byDescription: byDescription
                )
                results.append(contentsOf: childResults)
            }
        }
        
        return results
    }
    
    private static func buildElementTree(_ element: AXUIElement, depth: Int, maxDepth: Int) -> UIElementInfo? {
        guard depth < maxDepth else { return nil }
        guard var info = getElementInfo(element) else { return nil }
        
        var children: CFTypeRef?
        let childResult = AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &children)
        
        if childResult == .success, let childArray = children as? [AXUIElement] {
            let childInfos = childArray.compactMap { buildElementTree($0, depth: depth + 1, maxDepth: maxDepth) }
            info.children = childInfos.isEmpty ? nil : childInfos
        }
        
        return info
    }
}

private func getAttribute(_ element: AXUIElement, _ attribute: String) -> Any? {
    var value: CFTypeRef?
    let result = AXUIElementCopyAttributeValue(element, attribute as CFString, &value)
    return result == .success ? value : nil
}
