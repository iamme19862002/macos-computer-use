//
//  WindowManager.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import AppKit
import CoreGraphics
import Foundation

struct WindowInfo: Codable {
    let id: Int
    let appName: String
    let title: String
    let bounds: WindowBounds
    let isOnScreen: Bool
    let isMain: Bool
    let layer: Int
}

struct WindowBounds: Codable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double
}

struct WindowManager {
    
    static func listWindows(options: WindowListOptions = .all) -> [WindowInfo] {
        let windowList: CFArray?
        
        switch options {
        case .all:
            windowList = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID)
        case .onScreen:
            windowList = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID)
        case .ownedByApp:
            windowList = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID)
        }
        
        guard let windows = windowList as? [[String: Any]] else { return [] }
        
        return windows.compactMap { dict in
            guard let windowId = dict[kCGWindowNumber as String] as? Int,
                  let appPid = dict[kCGWindowOwnerPID as String] as? Int,
                  let appName = dict[kCGWindowOwnerName as String] as? String else {
                return nil
            }
            
            if case .ownedByApp(let filterPid) = options, appPid != filterPid {
                return nil
            }
            
            let bounds = dict[kCGWindowBounds as String] as? [String: CGFloat] ?? [:]
            let title = dict[kCGWindowName as String] as? String ?? ""
            let layer = dict[kCGWindowLayer as String] as? Int ?? 0
            let isOnScreen = dict[kCGWindowIsOnscreen as String] as? Bool ?? false
            
            return WindowInfo(
                id: windowId,
                appName: appName,
                title: title,
                bounds: WindowBounds(
                    x: bounds["X"] ?? 0,
                    y: bounds["Y"] ?? 0,
                    width: bounds["Width"] ?? 0,
                    height: bounds["Height"] ?? 0
                ),
                isOnScreen: isOnScreen,
                isMain: false,
                layer: layer
            )
        }
    }
    
    static func resize(windowId: Int, width: CGFloat, height: CGFloat) -> (success: Bool, message: String) {
        guard let window = findWindow(id: windowId) else {
            return (false, "Window \(windowId) not found")
        }
        
        let axWindow = AXUIElementCreateWindow(window.pid, CGWindowID(windowId))
        var size = CGSize(width: width, height: height)
        let sizeValue = AXValueCreate(.cgSize, &size)
        
        let result = AXUIElementSetAttributeValue(axWindow, kAXSizeAttribute as CFString, sizeValue!)
        
        return result == .success 
            ? (true, "Resized window \(windowId) to \(Int(width))x\(Int(height))")
            : (false, "Failed to resize window \(windowId)")
    }
    
    static func move(windowId: Int, x: CGFloat, y: CGFloat) -> (success: Bool, message: String) {
        guard let window = findWindow(id: windowId) else {
            return (false, "Window \(windowId) not found")
        }
        
        let axWindow = AXUIElementCreateWindow(window.pid, CGWindowID(windowId))
        var position = CGPoint(x: x, y: y)
        let positionValue = AXValueCreate(.cgPoint, &position)
        
        let result = AXUIElementSetAttributeValue(axWindow, kAXPositionAttribute as CFString, positionValue!)
        
        return result == .success 
            ? (true, "Moved window \(windowId) to (\(Int(x)), \(Int(y)))")
            : (false, "Failed to move window \(windowId)")
    }
    
    static func minimize(windowId: Int) -> (success: Bool, message: String) {
        guard let window = findWindow(id: windowId) else {
            return (false, "Window \(windowId) not found")
        }
        
        let axWindow = AXUIElementCreateWindow(window.pid, CGWindowID(windowId))
        let result = AXUIElementSetAttributeValue(axWindow, kAXMinimizedAttribute as CFString, true as CFTypeRef)
        
        return result == .success 
            ? (true, "Minimized window \(windowId)")
            : (false, "Failed to minimize window \(windowId)")
    }
    
    static func maximize(windowId: Int) -> (success: Bool, message: String) {
        guard let window = findWindow(id: windowId) else {
            return (false, "Window \(windowId) not found")
        }
        
        let axWindow = AXUIElementCreateWindow(window.pid, CGWindowID(windowId))
        let result = AXUIElementSetAttributeValue(axWindow, "AXMaximized" as CFString, true as CFTypeRef)
        
        return result == .success 
            ? (true, "Maximized window \(windowId)")
            : (false, "Failed to maximize window \(windowId)")
    }
    
    static func close(windowId: Int) -> (success: Bool, message: String) {
        guard let window = findWindow(id: windowId) else {
            return (false, "Window \(windowId) not found")
        }
        
        let axWindow = AXUIElementCreateWindow(window.pid, CGWindowID(windowId))
        let result = AXUIElementSetAttributeValue(axWindow, kAXCloseButtonAttribute as CFString, true as CFTypeRef)
        
        return result == .success 
            ? (true, "Closed window \(windowId)")
            : (false, "Failed to close window \(windowId)")
    }
    
    static func focus(windowId: Int) -> (success: Bool, message: String) {
        guard let window = findWindow(id: windowId) else {
            return (false, "Window \(windowId) not found")
        }
        
        let axWindow = AXUIElementCreateWindow(window.pid, CGWindowID(windowId))
        let result = AXUIElementSetAttributeValue(axWindow, kAXMainAttribute as CFString, true as CFTypeRef)
        
        return result == .success 
            ? (true, "Focused window \(windowId)")
            : (false, "Failed to focus window \(windowId)")
    }
    
    static func findWindow(id: Int) -> (pid: pid_t, window: [String: Any])? {
        let windowList = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as? [[String: Any]] ?? []
        
        for dict in windowList {
            if let windowId = dict[kCGWindowNumber as String] as? Int,
               windowId == id,
               let pid = dict[kCGWindowOwnerPID as String] as? Int32 {
                return (pid, dict)
            }
        }
        return nil
    }
    
    static func getActiveWindow() -> WindowInfo? {
        let windows = listWindows(options: .onScreen)
        return windows.first { $0.isOnScreen && $0.layer == 0 }
    }
    
    enum WindowListOptions {
        case all
        case onScreen
        case ownedByApp(pid_t)
    }
}

private func AXUIElementCreateWindow(_ pid: pid_t, _ windowID: CGWindowID) -> AXUIElement {
    let app = AXUIElementCreateApplication(pid)
    var window: CFTypeRef?
    AXUIElementCopyAttributeValue(app, kAXWindowsAttribute as CFString, &window)
    
    if let windows = window as? [AXUIElement] {
        for w in windows {
            var idValue: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(w, "AXWindowID" as CFString, &idValue)
            if result == .success,
               let num = idValue as? NSNumber,
               num.uint32Value == windowID {
                return w
            }
        }
    }
    return app
}
