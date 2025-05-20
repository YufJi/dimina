//
//  DMPLaunchConfig.swift
//  dimina
//
//  Created by Lehem on 2025/4/21.
//

import Foundation

public enum DMPOpenType {
    case navigateTo
    case insert
}

public enum DMPScene: Int {
  case fromMainEntry = 1001
  case fromMiniProgram = 1037
}

public struct DMPLaunchConfig {
    // 启动页面类型
    public var openType: DMPOpenType?
    // 启动页面路径
    public var appEntryPath: String?
    // 传递给页面参数
    public var query: [String: Any]?
    public var launchAnimated: Bool?
    public var isRelaunch: Bool?
    public var appOpenUrl: String?
    
    public init() {}
    
    public init(openType: DMPOpenType? = nil,
                appEntryPath: String? = nil,
                query: [String: Any]? = nil,
                launchAnimated: Bool? = nil,
                isRelaunch: Bool? = nil,
                appOpenUrl: String? = nil) {
        self.openType = openType
        self.appEntryPath = appEntryPath
        self.query = query
        self.launchAnimated = launchAnimated
        self.isRelaunch = isRelaunch
        self.appOpenUrl = appOpenUrl
    }
}



