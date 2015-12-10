//
//  NSUserDefaultsSerializer.swift
//  Queue
//
//  Created by ChenHao on 12/10/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

import UIKit

/// comfire the QueueSerializationProvider protocol to persistent the queue to the NSUserdefualts
public class NSUserDefaultsSerializer: QueueSerializationProvider {

    public init() { }
    
    public func serializeTask(task: QueueTask, queueName: String) {
        
    }
    
    public func deserialzeTasksInQueue(queue: Queue) -> [QueueTask] {
        return []
    }
    
    public func removeTask(taskID: String, queue: Queue) {
        
    }
}
