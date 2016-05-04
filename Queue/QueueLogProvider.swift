//
//  QueueLogProvider.swift
//  Queue
//
//  Created by ChenHao on 12/10/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

import Foundation

public enum LogLevel: Int {
    case Trace
    case Debug
    case Info
    case Warning
    case Error
    
    public func toString() -> String {
        switch (self) {
        case .Trace:   return "Trace"
        case .Debug:   return "Debug"
        case .Info:    return "Info"
        case .Warning: return "Warning"
        case .Error:   return "Error"
        }
    }
}

public protocol QueueLogProvider {
    func log(level: LogLevel, msg: String)
}
