//
//  QueueLogProvider.swift
//  Queue
//
//  Created by ChenHao on 12/10/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

import UIKit

public enum LogLevel: Int {
    case Trace
    case Debug
    case Info
    case Warning
    case Error
}

public protocol QueueLogProvider: NSObjectProtocol {

    func log(level: LogLevel, msg: String)
}
