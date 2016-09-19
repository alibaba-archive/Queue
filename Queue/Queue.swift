//
//  Queue.swift
//  Queue
//
//  Created by ChenHao on 12/9/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

import Foundation

// swiftlint:disable variable_name

open class Queue: OperationQueue {

    /// the max times of retries when the task failing
    open let maxRetries: Int
    var taskCallbacks = [String: TaskCallBack]()
    var taskList = [String: QueueTask]()
    let serializationProvider: QueueSerializationProvider?
    let logProvider: QueueLogProvider?
    let completeClosure: TaskCompleteCallback?

    public required init(queueName: String, maxConcurrency: Int = 1,
        maxRetries: Int = 5,
        serializationProvider: QueueSerializationProvider? = nil,
        logProvider: QueueLogProvider? = nil,
        completeClosure: TaskCompleteCallback?) {

            self.maxRetries = maxRetries
            self.serializationProvider = serializationProvider
            self.logProvider = logProvider
            self.completeClosure = completeClosure
            super.init()
            self.name = queueName
            self.maxConcurrentOperationCount = maxConcurrency
    }

    open func hasUnfinishedTask() -> Bool {
        if let provider = serializationProvider {
            return provider.deserialzeTasks(self).count > 0
        }
        return false
    }

    /**
     load the unfinish tasks to Queue
     */
    open func loadSerializeTaskToQueue() {
        self.pause()
        log(LogLevel.trace, msg: "暂停队列 载入序列化任务")
        let tasks = serializationProvider?.deserialzeTasks(self)
        for task in tasks! {
            addDeserializedTask(task)
        }
        log(LogLevel.trace, msg: "载入成功 队列启动")
        self.start()
    }

    /**
     addDeserializedTask

     - parameter task: task array
     */
    open func addDeserializedTask(_ task: QueueTask) {
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
    open func addTaskCallback(_ taskType: String, taskCallBack: @escaping TaskCallBack) {
        taskCallbacks[taskType] = taskCallBack
    }

    /**
     add Queue task to the queue and it will automaticly invoke the start method

     - parameter op: Queuetask
     */
    open override func addOperation(_ op: Operation) {
        if let task = op as? QueueTask {
            if taskList[task.taskID] != nil {
                log(.warning, msg: "Attempted to add duplicate task\(task.taskID)")
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

    open func start() {
        self.isSuspended = false
    }

    open func pause() {
        self.isSuspended = true
    }

    func runTask(_ task: QueueTask) {
        if let callback = taskCallbacks[task.taskType] {
             callback(task)
        } else {
            log(LogLevel.error, msg: "no callback registerd for task")
        }
    }

    func taskComplete(_ op: Operation) {
        if let task = op as? QueueTask {
            taskList.removeValue(forKey: task.taskID)

            if let handle = completeClosure {
                handle(task, task.error)
            }

            if let sp = serializationProvider {
                sp.removeTask(task.taskID, queue: task.queue)
            }
        }
    }

    func log(_ level: LogLevel, msg: String) {
        logProvider?.log(level, msg: msg)
    }
}
