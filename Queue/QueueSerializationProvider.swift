//
//  QueueSerializationProvider.swift
//  Queue
//
//  Created by ChenHao on 12/10/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

/**
*  comfire to this protocol to provide serialization Queue
*/

public protocol QueueSerializationProvider {
    func serializeTask(_ task: QueueTask, queueName: String)
    func deserialzeTasks(_ queue: Queue) -> [QueueTask]
    func removeTask(_ taskID: String, queue: Queue)
}

