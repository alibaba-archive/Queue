//
//  NSUserDefaultsSerializer.swift
//  Queue
//
//  Created by ChenHao on 12/10/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

import Foundation

/// comfire the QueueSerializationProvider protocol to persistent the queue to the NSUserdefualts
open class NSUserDefaultsSerializer: QueueSerializationProvider {

    public init() { }

    open func serializeTask(_ task: QueueTask, queueName: String) {
        if let serialized = task.toJSONString() {
            let defaults = UserDefaults.standard
            var stringArray: [String]

            if let curStringArray = defaults.stringArray(forKey: queueName) {
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

    open func deserialzeTasks(_ queue: Queue) -> [QueueTask] {
        let defaults = UserDefaults.standard
        if  let queneName = queue.name,
            let stringArray = defaults.stringArray(forKey: queneName) {
                print(stringArray.count)
                    //.map { return QueueTask(json: $0, queue: queue)})

                return stringArray
                    .map { return QueueTask(json: $0, queue: queue)}
                    .filter { return $0 != nil }
                    .map { return $0! }
        }
        return []
    }

    open func removeTask(_ taskID: String, queue: Queue) {
        if let queueName = queue.name {
            var curArray: [QueueTask] = deserialzeTasks(queue)
            curArray = curArray.filter {return $0.taskID != taskID }
            let stringArray = curArray
                .map {return $0.toJSONString() }
                .filter { return $0 != nil}
                .map { return $0! }
            UserDefaults.standard.setValue(stringArray, forKey: queueName)
        }
    }
}
