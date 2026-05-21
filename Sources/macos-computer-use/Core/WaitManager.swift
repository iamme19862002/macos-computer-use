//
//  WaitManager.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct WaitManager {
    
    static func waitForElement(
        role: String? = nil,
        title: String? = nil,
        identifier: String? = nil,
        description: String? = nil,
        inApp: String? = nil,
        timeout: Double,
        interval: Double = 0.5
    ) -> (found: Bool, element: UIElementInfo?, waited: Double) {
        let startTime = Date()
        
        while Date().timeIntervalSince(startTime) < timeout {
            let results = AccessibilityManager.findElements(
                byRole: role,
                byTitle: title,
                byIdentifier: identifier,
                byDescription: description,
                inApp: inApp
            )
            
            if let first = results.first {
                return (true, first.info, Date().timeIntervalSince(startTime))
            }
            
            Thread.sleep(forTimeInterval: interval)
        }
        
        return (false, nil, Date().timeIntervalSince(startTime))
    }
    
    static func waitForApp(
        appName: String,
        timeout: Double,
        interval: Double = 0.5
    ) -> (found: Bool, waited: Double) {
        let startTime = Date()
        
        while Date().timeIntervalSince(startTime) < timeout {
            let apps = AppManager.findRunningApps(named: appName)
            if !apps.isEmpty {
                return (true, Date().timeIntervalSince(startTime))
            }
            
            Thread.sleep(forTimeInterval: interval)
        }
        
        return (false, Date().timeIntervalSince(startTime))
    }
    
    static func sleep(milliseconds: Int) {
        usleep(useconds_t(milliseconds * 1000))
    }
}
