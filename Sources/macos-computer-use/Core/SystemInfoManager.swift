//
//  SystemInfoManager.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import AppKit
import CoreGraphics
import Foundation

struct DisplayInfo: Codable {
    let id: UInt32
    let width: Int
    let height: Int
    let bounds: WindowBounds
    let isMain: Bool
}

struct SystemInfo: Codable {
    let osVersion: String
    let swiftVersion: String
    let cpuCount: Int
    let physicalMemory: UInt64
    let hostname: String
}

struct SystemInfoManager {
    
    static func getScreenInfo() -> WindowBounds {
        let screen = NSScreen.main
        let frame = screen?.frame ?? .zero
        return WindowBounds(
            x: Double(frame.origin.x),
            y: Double(frame.origin.y),
            width: Double(frame.size.width),
            height: Double(frame.size.height)
        )
    }
    
    static func getDisplayList() -> [DisplayInfo] {
        let displays = NSScreen.screens
        return displays.enumerated().map { index, screen in
            let frame = screen.frame
            let displayID = CGDirectDisplayID(index)
            return DisplayInfo(
                id: displayID,
                width: Int(frame.size.width),
                height: Int(frame.size.height),
                bounds: WindowBounds(
                    x: Double(frame.origin.x),
                    y: Double(frame.origin.y),
                    width: Double(frame.size.width),
                    height: Double(frame.size.height)
                ),
                isMain: screen == NSScreen.main
            )
        }
    }
    
    static func getSystemInfo() -> SystemInfo {
        let processInfo = ProcessInfo.processInfo
        
        return SystemInfo(
            osVersion: processInfo.operatingSystemVersionString,
            swiftVersion: "5.9",
            cpuCount: processInfo.processorCount,
            physicalMemory: processInfo.physicalMemory,
            hostname: processInfo.hostName
        )
    }
}
