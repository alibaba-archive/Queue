//
//  Queue.swift
//  Queue
//
//  Created by ChenHao on 12/9/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

import Foundation

public class Queue: NSOperationQueue {
    
    /// the max times of retries when the task failing
    public let maxRetries: Int
    var taskCallbacks = [String: TaskCallBack]()
    var taskList = [String: QueueTask]()
    let serializationProvider: QueueSerializationProvider?
    let logProvider: QueueLogProvider?
    
    public required init(queueName: String, maxConcurrency: Int = 1,
        maxRetries: Int = 5,
        serializationProvider: QueueSerializationProvider? = nil,
        logProvider: QueueLogProvider? = nil) {
            
            self.maxRetries = maxRetries
            self.serializationProvider = serializationProvider
            self.logProvider = logProvider
            super.init()
            self.name = queueName
            self.maxConcurrentOperationCount = maxConcurrency
    }
    
    
    /**
     load the unfinish tasks to Queue
     */
    public func loadSerializeTaskToQueue() {
        let tasks = serializationProvider?.deserialzeTasksInQueue(self)
        for task in tasks! {
            addDeserializedTask(task)
        }
    }
    
    /**
     addDeserializedTask
     
     - parameter task: task array
     */
    public func addDeserializedTask(task: QueueTask) {
        if taskList[task.taskID] != nil {
            return
        }
        task.completionBlock = { self.taskComplete(task)}
        super.addOperation(task)
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
        }
        op.completionBlock = { self.taskComplete(op) }
        super.addOperation(op)
    }
    
    public func start() {
        self.suspended = false
    }
    
    public func pause() {
        self.suspended = true
    }
    
    func runTask(task: QueueTask) {
        if let callback = taskCallbacks[task.taskType] {
             callback(task)
        } else {
            log(LogLevel.Error, msg: "no callback registerd for task")
        }
    }
    
    func taskComplete(op: NSOperation) {
        if let task = op as? QueueTask {
            taskList.removeValueForKey(task.taskID)
        }
    }
    
    func log(level: LogLevel, msg: String) {
        logProvider?.log(level, msg: msg)
    }

}
