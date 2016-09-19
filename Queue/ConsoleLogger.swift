//
//  ConsoleLogProvider.swift
//  Queue
//
//  Created by ChenHao on 12/10/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

import Foundation

open class ConsoleLogger: QueueLogProvider {

    public init() { }

    open func log(_ level: LogLevel, msg: String) {
        print("[\(level.toString())] \(msg)")
    }
}
