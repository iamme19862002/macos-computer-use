//
//  Recorder.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct RecordedAction: Codable {
    let timestamp: Double
    let type: String
    let params: [String: String]
}

struct Recorder {
    private static var actions: [RecordedAction] = []
    private static var startTime: Date?
    private static var isRecording = false
    
    static func startRecording() {
        actions = []
        startTime = Date()
        isRecording = true
    }
    
    static func stopRecording() -> [RecordedAction] {
        isRecording = false
        return actions
    }
    
    static func record(type: String, params: [String: String]) {
        guard isRecording, let start = startTime else { return }
        
        let action = RecordedAction(
            timestamp: Date().timeIntervalSince(start),
            type: type,
            params: params
        )
        actions.append(action)
    }
    
    static func saveToFile(_ filename: String) -> Bool {
        do {
            let data = try JSONEncoder().encode(actions)
            try data.write(to: URL(fileURLWithPath: filename))
            return true
        } catch {
            return false
        }
    }
    
    static func loadFromFile(_ filename: String) -> [RecordedAction]? {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filename))
            return try JSONDecoder().decode([RecordedAction].self, from: data)
        } catch {
            return nil
        }
    }
}
