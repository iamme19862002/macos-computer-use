//
//  CommandResult.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum ExitStatus: Int, Codable {
    case success = 0
    case invalidArguments = 1
    case targetNotFound = 2
    case permissionDenied = 3
    case timeout = 4
    case executionFailed = 5
    case assertionFailed = 6
    case internalError = 99
}

struct CommandResult: Codable {
    let success: Bool
    let data: [String: AnyCodable]?
    let error: CommandError?
    let timestamp: String

    init(success: Bool, data: [String: Any]? = nil, error: CommandError? = nil) {
        self.success = success
        self.data = data?.mapValues { AnyCodable($0) }
        self.error = error
        self.timestamp = ISO8601DateFormatter().string(from: Date())
    }

    func printJSON(pretty: Bool = true) {
        let encoder = JSONEncoder()
        if pretty {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        }
        if let data = try? encoder.encode(self),
           let json = String(data: data, encoding: .utf8) {
            print(json)
        }
    }
}

struct CommandError: Codable {
    let code: ExitStatus
    let message: String
    let details: String?

    init(code: ExitStatus, message: String, details: String? = nil) {
        self.code = code
        self.message = message
        self.details = details
    }
}

struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else {
            value = ""
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let string = value as? String {
            try container.encode(string)
        } else if let int = value as? Int {
            try container.encode(int)
        } else if let double = value as? Double {
            try container.encode(double)
        } else if let bool = value as? Bool {
            try container.encode(bool)
        } else if let array = value as? [Any] {
            try container.encode(array.map { AnyCodable($0) })
        } else if let dict = value as? [String: Any] {
            try container.encode(dict.mapValues { AnyCodable($0) })
        } else {
            try container.encode("\(value)")
        }
    }
}
