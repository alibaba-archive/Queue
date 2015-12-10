//
//  Queue.swift
//  Queue
//
//  Created by ChenHao on 12/9/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

import Foundation

public class Queue: NSOperationQueue {
    
    public let maxRetries: Int
    var taskCallbacks = [String: TaskCallBack]()
    var taskList = [String: QueueTask]()
    let serializationProvider: QueueSerializationProvider?
    
    public required init(queueName: String, maxConcurrency: Int = 1,
        maxRetries: Int = 5,
        serializationProvider: QueueSerializationProvider? = nil) {
            
            self.maxRetries = maxRetries
            self.serializationProvider = serializationProvider
            super.init()
            self.name = queueName
            self.maxConcurrentOperationCount = maxConcurrency
    }
    
    /**
     register a callback for type of queuetask
     
     - parameter taskType:     The task type for the callback
     - parameter taskCallBack: The callback for particular task
     */
    public func addTaskCallback(taskType: String, taskCallBack: TaskCallBack) {
        taskCallbacks[taskType] = taskCallBack
    }
    
    /**
     add Queue task to the queue and it will automaticly invoke the start method
     
     - parameter op: Queuetask
     */
    public override func addOperation(op: NSOperation) {
        if let task = op as? QueueTask {
            taskList[task.taskID] = task
            print(taskList)
        }
        super.addOperation(op)
    }
    
    func runTask(task: QueueTask) {
        if let callback = taskCallbacks[task.taskType] {
             callback(task)
        } else {
            print("no callback registerd for task")
        }
    }
    
    func taskComplete(op: NSOperation) {
        if let task = op as? QueueTask {
            taskList.removeValueForKey(task.taskID)
        }
    }

}
