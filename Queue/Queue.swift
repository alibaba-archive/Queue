//
//  Queue.swift
//  Queue
//
//  Created by ChenHao on 12/9/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

import UIKit

public class Queue: NSOperationQueue {
    
    public let maxRetries: Int
    
    var taskCallbacks = [String: TaskCallBack]()
    
    public required init(queueName: String, maxConcurrency: Int = 1,
        maxRetries: Int = 5,
        serializationProvider: String? = nil) {
        
            self.maxRetries = maxRetries
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
    
    func runTask(task: QueueTask) {
        
    }

}
