//
//  ConsoleLogProvider.swift
//  Queue
//
//  Created by ChenHao on 12/10/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

import UIKit

public class ConsoleLogger: QueueLogProvider {
    
    public init() { }
    
    public func log(level: LogLevel, msg: String) {
        print("[\(level.toString())] \(msg)")
    }
}
