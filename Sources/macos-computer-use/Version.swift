//
//  Version.swift
//  macos-computer-use
//
//  Created by macos-computer-use authors on 2026.
//  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// 应用版本管理
/// 所有版本号相关的地方都应该引用这个文件中的常量
enum AppVersion {
    /// 当前版本号
    /// 格式: 主版本号.次版本号.修订号
    static let current = "3.5.0"
    
    /// 主版本号
    static let major = 3
    
    /// 次版本号
    static let minor = 5
    
    /// 修订号
    static let patch = 0
}
