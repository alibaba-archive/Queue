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

    public init() { }
    
    public func serializeTask(task: QueueTask, queueName: String) {
        if let serialized = task.toJSONString() {
            let defaults = NSUserDefaults.standardUserDefaults()
            var stringArray: [String]
            
            if let curStringArray = defaults.stringArrayForKey(queueName) {
                stringArray = curStringArray
                stringArray.append(serialized)
            } else {
                stringArray = [serialized]
            }
            defaults.setValue(stringArray, forKey: queueName)
            defaults.synchronize()
            print("序列化成功")
        } else {
            print("序列化失败")
        }
    }
    
    public func deserialzeTasksInQueue(queue: Queue) -> [QueueTask] {
        let defaults = NSUserDefaults.standardUserDefaults()
        if  let queneName = queue.name,
            let stringArray = defaults.stringArrayForKey(queneName) {
                print(stringArray.count)
                    //.map { return QueueTask(json: $0, queue: queue)})
                
                return stringArray
                    .map { return QueueTask(json: $0, queue: queue)}
                    .filter { return $0 != nil }
                    .map { return $0! }
        }
        return []
    }
    
    public func removeTask(taskID: String, queue: Queue) {
        if let queueName = queue.name {
            var curArray: [QueueTask] = deserialzeTasksInQueue(queue)
            curArray = curArray.filter {return $0.taskID != taskID }
            let stringArray = curArray
                .map {return $0.toJSONString() }
                .filter { return $0 != nil}
                .map { return $0! }
            NSUserDefaults.standardUserDefaults().setValue(stringArray, forKey: queueName)
        }
    }
}
