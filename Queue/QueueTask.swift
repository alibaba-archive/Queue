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
    public let created: NSDate
    public var started: NSDate?
    public var userInfo: AnyObject?
    
    var _executing: Bool = false
    var _finished: Bool = false
    
    public override var name: String? {get {return taskID } set { } }
    
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
    
    /**
     Initializes a new QueueTask with following paramsters
     
     - parameter queue:    the queue the execute the task
     - parameter taskID:   A unique identifer for the task
     - parameter taskType: A type that will be used to group tasks together, tasks have to be generic with respect to their type
     - parameter userInfo: other infomation
     - parameter created:  When the task was created
     - parameter started:  When the task was started first time
     - parameter retries:  Number of times this task has been retries after failing
     
     - returns: A new QueueTask
     */
    private init(queue: Queue, taskID: String? = nil, taskType: String, userInfo: AnyObject? = nil,
        created: NSDate = NSDate(), started: NSDate? = nil ,
        retries: Int = 0) {
            self.queue = queue
            self.taskID = taskID ?? NSUUID().UUIDString
            self.taskType = taskType
            self.retries = retries
            self.created = created
            self.userInfo = userInfo
        super.init()
    }
    
    public convenience init(queue: Queue, type: String, userInfo: AnyObject? = nil, retries: Int = 0) {
        self.init(queue:queue, taskType: type, userInfo:userInfo, retries:retries)
    }
    
    public func toJSONString() -> String? {
        let dict = toDictionary()
        
        let nsdict = NSMutableDictionary(capacity: dict.count)
        for (key, value) in dict {
            nsdict[key] = value ?? NSNull()
        }
        do {
            let json = try toJSON(nsdict)
            return json
        } catch {
            return nil
        }
    }
    
    private func toJSON(obj: AnyObject) throws -> String? {
        let json = try NSJSONSerialization.dataWithJSONObject(obj, options: [])
        return NSString(data: json, encoding: NSUTF8StringEncoding) as String?
    }
    
    public func toDictionary() -> [String: AnyObject?] {
        var dict = [String: AnyObject?]()
        
        dict["taskID"] = self.taskID
        dict["taskType"] = self.taskType
        return dict
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
