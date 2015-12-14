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
    
    public func hasUnfinishedTask() -> Bool {
        return serializationProvider?.deserialzeTasksInQueue(self).count > 0
    }
    
    /**
     load the unfinish tasks to Queue
     */
    public func loadSerializeTaskToQueue() {
        self.pause()
        log(LogLevel.Trace, msg: "暂停队列 载入序列化任务")
        let tasks = serializationProvider?.deserialzeTasksInQueue(self)
        for task in tasks! {
            addDeserializedTask(task)
        }
        log(LogLevel.Trace, msg: "载入成功 队列启动")
        self.start()
    }
    
    /**
     addDeserializedTask
     
     - parameter task: task array
     */
    public func addDeserializedTask(task: QueueTask) {
        if taskList[task.taskID] != nil {
            return
        }
        taskList[task.taskID] = task
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
            if taskList[task.taskID] != nil {
                log(.Warning, msg: "Attempted to add duplicate task\(task.taskID)")
            }
            taskList[task.taskID] = task
            if  let sp = serializationProvider,
                let queueName = task.queue.name {
                sp.serializeTask(task, queueName: queueName)
            }
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
            
            if let sp = serializationProvider {
                sp.removeTask(task.taskID, queue: task.queue)
            }
        }
    }
    
    func log(level: LogLevel, msg: String) {
        logProvider?.log(level, msg: msg)
    }

}
