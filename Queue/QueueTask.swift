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
public typealias JSONDictionary = [String: AnyObject]

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
    
    
    // MARK: - Init
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
    
    public convenience init?(dictionary: JSONDictionary, queue: Queue) {
        if  let taskID = dictionary["taskID"] as? String,
            let taskType = dictionary["taskType"] as? String,
            let data: AnyObject? = dictionary["userInfo"] as AnyObject??,
            let createdStr = dictionary["created"] as? String,
            let startedStr: String? = dictionary["started"] as? String ?? nil,
            let retries = dictionary["retries"] as? Int? ?? 0
        {
            let created = NSDate(dateString: createdStr) ?? NSDate()
            let started = (startedStr != nil) ? NSDate(dateString: startedStr!) : nil
            self.init(queue: queue, taskID: taskID, taskType: taskType, userInfo: data, created: created,
                started: started, retries: retries)
        } else {
            self.init(queue: queue, taskID: "", taskType: "")
            return nil
        }
    }
    
    public convenience init?(json: String, queue: Queue) {
        do {
            if let dict = try fromJSON(json) as? [String: AnyObject] {
                self.init(dictionary: dict, queue: queue)
            } else {
                return nil
            }
        } catch {
            return nil
        }
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
    
    public func toDictionary() -> [String: AnyObject?] {
        var dict = [String: AnyObject?]()
        
        dict["taskID"] = self.taskID
        dict["taskType"] = self.taskType
        return dict
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
     
     - parameter error: if the task failed, pass an error to indicate why
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
            queue.log(LogLevel.Debug, msg: "Task \(taskID) retry \(retries) times")
            self.run()
        } else {
            queue.log(LogLevel.Trace, msg: "Task \(taskID) completed \(queue.taskList.count) tasks left")
            finished = true
        }
    }
    
    // MARK: - overide method
    public override func start() {
        super.start()
        executing = true
        run()
    }
    
    public override func cancel() {
        super.cancel()
        finished = true
    }
    
    
}

//  MARK: - NSDate extention
extension NSDate {
    convenience init?(dateString:String) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        if let d = formatter.dateFromString(dateString) {
            self.init(timeInterval:0, sinceDate:d)
        } else {
            self.init(timeInterval:0, sinceDate:NSDate())
            return nil
        }
    }
    
    var isoFormatter: ISOFormatter {
        if let formatter = objc_getAssociatedObject(self, "formatter") as? ISOFormatter {
            return formatter
        } else {
            let formatter = ISOFormatter()
            objc_setAssociatedObject(self, "formatter", formatter, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            return formatter
        }
    }
    
    func toISOString() -> String {
        return self.isoFormatter.stringFromDate(self)
    }
}

class ISOFormatter : NSDateFormatter {
    override init() {
        super.init()
        self.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        self.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        self.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

//  MARK: - Hepler
private func toJSON(obj: AnyObject) throws -> String? {
    let json = try NSJSONSerialization.dataWithJSONObject(obj, options: [])
    return NSString(data: json, encoding: NSUTF8StringEncoding) as String?
}

private func fromJSON(str: String) throws -> AnyObject? {
    if let json = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
        let obj: AnyObject = try NSJSONSerialization.JSONObjectWithData(json, options: .AllowFragments)
        return obj
    }
    return nil
}

private func runInBackgroundAfter(seconds: NSTimeInterval, callback:dispatch_block_t) {
    let delta = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds) * Int64(NSEC_PER_SEC))
    dispatch_after(delta, dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), callback)
}
