//
//  AppManager.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import AppKit
import Foundation

struct AppInfo: Codable {
    let name: String
    let bundleIdentifier: String?
    let pid: Int
    let isActive: Bool
    let isHidden: Bool
    let windowCount: Int
}

struct AppManager {
    
    static func launch(appName: String, wait: Bool = false) -> (success: Bool, message: String, pid: Int?) {
        let workspace = NSWorkspace.shared
        
        if let url = workspace.urlForApplication(withBundleIdentifier: appName) {
            return launchApp(at: url, wait: wait)
        }
        
        if let url = findApp(named: appName) {
            return launchApp(at: url, wait: wait)
        }
        
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        task.arguments = ["-a", appName]
        if wait {
            task.arguments?.append("-W")
        }
        
        do {
            try task.run()
            if wait {
                task.waitUntilExit()
            }
            return (true, "Launched \(appName)", Int(task.processIdentifier))
        } catch {
            return (false, "Failed to launch \(appName): \(error.localizedDescription)", nil)
        }
    }
    
    static func launchApp(at url: URL, wait: Bool = false) -> (success: Bool, message: String, pid: Int?) {
        let workspace = NSWorkspace.shared
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        
        var resultPid: Int?
        let semaphore = DispatchSemaphore(value: 0)
        
        workspace.openApplication(at: url, configuration: configuration) { runningApp, error in
            if let app = runningApp {
                resultPid = Int(app.processIdentifier)
            }
            semaphore.signal()
        }
        
        if wait {
            semaphore.wait()
        }
        
        return (resultPid != nil, "Launched \(url.lastPathComponent)", resultPid)
    }
    
    static func findApp(named: String) -> URL? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/mdfind")
        task.arguments = ["kMDItemContentType == 'com.apple.application-bundle' && kMDItemDisplayName == '\(named)'cd"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
               !output.isEmpty {
                return URL(fileURLWithPath: output.components(separatedBy: "\n").first!)
            }
        } catch {
            return nil
        }
        return nil
    }
    
    static func quit(appName: String, force: Bool = false) -> (success: Bool, message: String) {
        let apps = findRunningApps(named: appName)
        
        guard !apps.isEmpty else {
            return (false, "App '\(appName)' not found")
        }
        
        for app in apps {
            if force {
                app.forceTerminate()
            } else {
                app.terminate()
            }
        }
        
        return (true, "Quit \(apps.count) instance(s) of \(appName)")
    }
    
    static func activate(appName: String) -> (success: Bool, message: String) {
        let apps = findRunningApps(named: appName)
        
        guard let app = apps.first else {
            let launchResult = launch(appName: appName)
            return launchResult.success 
                ? (true, "Launched and activated \(appName)")
                : (false, "Failed to activate \(appName)")
        }
        
        app.activate(options: .activateAllWindows)
        return (true, "Activated \(appName)")
    }
    
    static func hide(appName: String) -> (success: Bool, message: String) {
        let apps = findRunningApps(named: appName)
        
        guard let app = apps.first else {
            return (false, "App '\(appName)' not found")
        }
        
        app.hide()
        return (true, "Hidden \(appName)")
    }
    
    static func unhide(appName: String) -> (success: Bool, message: String) {
        let apps = findRunningApps(named: appName)
        
        guard let app = apps.first else {
            return (false, "App '\(appName)' not found")
        }
        
        app.unhide()
        return (true, "Unhidden \(appName)")
    }
    
    static func listRunningApps() -> [AppInfo] {
        let workspace = NSWorkspace.shared
        let runningApps = workspace.runningApplications
        
        return runningApps.map { app in
            AppInfo(
                name: app.localizedName ?? "Unknown",
                bundleIdentifier: app.bundleIdentifier,
                pid: Int(app.processIdentifier),
                isActive: app.isActive,
                isHidden: app.isHidden,
                windowCount: 0
            )
        }
    }
    
    static func findRunningApps(named: String) -> [NSRunningApplication] {
        let workspace = NSWorkspace.shared
        let lowercased = named.lowercased()
        
        return workspace.runningApplications.filter { app in
            // Exact match first
            let exactName = app.localizedName?.lowercased() == lowercased
            let exactBundle = app.bundleIdentifier?.lowercased() == lowercased
            
            // Then try contains match
            let containsName = app.localizedName?.lowercased().contains(lowercased) ?? false
            let containsBundle = app.bundleIdentifier?.lowercased().contains(lowercased) ?? false
            
            return exactName || exactBundle || containsName || containsBundle
        }.sorted { app1, app2 in
            // Sort exact matches first
            let e1 = app1.localizedName?.lowercased() == lowercased
            let e2 = app2.localizedName?.lowercased() == lowercased
            return e1 && !e2
        }
    }
    
    static func getFrontmostApp() -> AppInfo? {
        let workspace = NSWorkspace.shared
        guard let app = workspace.frontmostApplication else { return nil }
        
        return AppInfo(
            name: app.localizedName ?? "Unknown",
            bundleIdentifier: app.bundleIdentifier,
            pid: Int(app.processIdentifier),
            isActive: app.isActive,
            isHidden: app.isHidden,
            windowCount: 0
        )
    }
}
