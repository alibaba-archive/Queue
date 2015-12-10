//
//  QueueTask.swift
//  Queue
//
//  Created by ChenHao on 12/10/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

import Foundation

public typealias TaskCallBack = (QueueTask) -> Void
public typealias TaskCompleteCallback = (QueueTask, NSError?) -> Void


public class QueueTask: NSOperation {
    
    public let queue: Queue
    public var taskID: String
    public var taskType: String
    public var retries: Int
    var _executing: Bool = false
    var _finished: Bool = false
    
    public override var executing: Bool {
        get { return _executing }
        set {
            willChangeValueForKey("isExecuting")
            _executing = newValue
            didChangeValueForKey("isExecuting")
        }
    }
    public override var finished: Bool {
        get { return _finished }
        set {
            willChangeValueForKey("isFinished")
            _finished = newValue
            didChangeValueForKey("isFinished")
        }
    }
    
    
    private init(queue: Queue, taskID: String? = nil, taskType: String, data: AnyObject? = nil,
        created: NSDate = NSDate(), started: NSDate? = nil ,
        retries: Int = 0) {
            self.queue = queue
            self.taskID = taskID ?? NSUUID().UUIDString
            self.taskType = taskType
            self.retries = retries
        super.init()
    }
    
    public convenience init(queue: Queue, type: String, data: AnyObject? = nil, retries: Int = 0) {
        self.init(queue:queue, taskType: type, data:data, retries:retries)
    }
    
    public override func start() {
        super.start()
        executing = true
        run()
    }
    
    public override func cancel() {
        super.cancel()
        finished = true
    }
    
    /**
     run the task on the queue
     */
    func run() {
        if cancelled && !finished { finished = true }
        if finished { return }
        queue.runTask(self)
    }
    
    /**
     invoke the method to tell the queue if has error when the task complete
     
     - parameter error: error
     */
    public func complete(error: NSError?) {
        if (!executing) {
            return
        }
        
        if let _ = error {
            if ++retries >= queue.maxRetries {
                cancel()
                return
            }
            self.run()
        } else {
            print("Task \(taskID) completed")
            finished = true
        }
    }
    
}
