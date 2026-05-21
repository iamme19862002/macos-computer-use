//
//  JSONUtils.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

func printJSON(_ dict: [String: Any]) {
    do {
        let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        if let jsonString = String(data: data, encoding: .utf8) {
            print(jsonString)
        }
    } catch {
        print("{\"error\": \"JSON serialization failed\"}")
    }
}
