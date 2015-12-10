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
    func serializeTask(task: QueueTask, queueName: String)
    func deserialzeTasksInQueue(queue: Queue) -> [QueueTask]
    func removeTask(taskID: String, queue: Queue)
}
