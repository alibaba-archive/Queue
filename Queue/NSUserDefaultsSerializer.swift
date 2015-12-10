//
//  NSUserDefaultsSerializer.swift
//  Queue
//
//  Created by ChenHao on 12/10/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

import Foundation

/// comfire the QueueSerializationProvider protocol to persistent the queue to the NSUserdefualts
public class NSUserDefaultsSerializer: QueueSerializationProvider {

    public func serializeTask(task: QueueTask, queueName: String) {
        
    }
    
    public func deserialzeTasksInQueue(queue: Queue) -> [QueueTask] {
        let defaults = NSUserDefaults.standardUserDefaults()
        if  let queneName = queue.name,
            let stringArray = defaults.stringArrayForKey(queneName) {
                //return stringArray.map
//                return stringArray.map { }
        }
        return []
    }
    
    public func removeTask(taskID: String, queue: Queue) {
        
    }
}
