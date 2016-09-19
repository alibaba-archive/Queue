//
//  QueueLogProvider.swift
//  Queue
//
//  Created by ChenHao on 12/10/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

import Foundation

public enum LogLevel: Int {
    case trace
    case debug
    case info
    case warning
    case error

    public func toString() -> String {
        switch self {
        case .trace:   return "Trace"
        case .debug:   return "Debug"
        case .info:    return "Info"
        case .warning: return "Warning"
        case .error:   return "Error"
        }
    }
}

public protocol QueueLogProvider {
    func log(_ level: LogLevel, msg: String)
}
