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

// swiftlint:disable line_length
// swiftlint:disable variable_name

open class QueueTask: Operation {

    open let queue: Queue
    open var taskID: String
    open var taskType: String
    open var retries: Int
    open let created: Date
    open var started: Date?
    open var userInfo: AnyObject?
    var error: NSError?

    var _executing: Bool = false
    var _finished: Bool = false

    open override var name: String? {get {return taskID } set { } }

    open override var isExecuting: Bool {
        get { return _executing }
        set {
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }
    open override var isFinished: Bool {
        get { return _finished }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
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
    fileprivate init(queue: Queue, taskID: String? = nil, taskType: String, userInfo: AnyObject? = nil,
        created: Date = Date(), started: Date? = nil ,
        retries: Int = 0) {
            self.queue = queue
            self.taskID = taskID ?? UUID().uuidString
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
            let startedStr = dictionary["started"] as? String,
            let retries = dictionary["retries"] as? Int? ?? 0 {
            let created = Date(dateString: createdStr) ?? Date()
            let started = Date(dateString: startedStr)

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

    open func toJSONString() -> String? {
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

    open func toDictionary() -> [String: AnyObject?] {
        var dict = [String: AnyObject?]()

        dict["taskID"] = self.taskID as AnyObject
        dict["taskType"] = self.taskType as AnyObject
        dict["created"] = self.created.toISOString() as AnyObject
        dict["retries"] = self.retries as AnyObject
        dict["userInfo"] = self.userInfo

        if let started = self.started {
            dict["started"] = started.toISOString() as AnyObject
        }
        return dict
    }

    /**
     run the task on the queue
     */
    func run() {
        if isCancelled && !isFinished { isFinished = true }
        if isFinished { return }
        queue.runTask(self)
    }

    /**
     invoke the method to tell the queue if has error when the task complete

     - parameter error: if the task failed, pass an error to indicate why
     */
    open func complete(_ error: NSError?) {
        if !isExecuting {
            return
        }
        if let error = error {
            self.error = error
            retries += 1
            if retries >= queue.maxRetries {
                cancel()
                queue.log(LogLevel.trace, msg: "Task \(taskID) failed \(queue.taskList.count) tasks left")
                return
            }
            queue.log(LogLevel.debug, msg: "Task \(taskID) retry \(retries) times")
            self.run()
        } else {
            queue.log(LogLevel.trace, msg: "Task \(taskID) completed \(queue.taskList.count) tasks left")
            isFinished = true
        }
    }

    // MARK: - overide method
    open override func start() {
        super.start()
        isExecuting = true
        run()
    }

    open override func cancel() {
        super.cancel()
        isFinished = true
    }


}

//  MARK: - NSDate extention
extension Date {
    init?(dateString: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        if let d = formatter.date(from: dateString) {
            self.init(timeInterval:0, since:d)
        } else {
            self.init(timeInterval:0, since:Date())
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
        return self.isoFormatter.string(from: self)
    }
}

class ISOFormatter: DateFormatter {
    override init() {
        super.init()
        self.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        self.timeZone = TimeZone(secondsFromGMT: 0)
        self.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

//  MARK: - Hepler
private func toJSON(_ obj: AnyObject) throws -> String? {
    let json = try JSONSerialization.data(withJSONObject: obj, options: [])
    return NSString(data: json, encoding: String.Encoding.utf8.rawValue) as String?
}

private func fromJSON(_ str: String) throws -> AnyObject? {
    if let json = str.data(using: String.Encoding.utf8, allowLossyConversion: false) {
        let obj: AnyObject = try JSONSerialization.jsonObject(with: json, options: .allowFragments) as AnyObject
        return obj
    }
    return nil
}

private func runInBackgroundAfter(_ seconds: TimeInterval, callback:@escaping ()->()) {
    let delta = DispatchTime.now() + Double(Int64(seconds) * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
    DispatchQueue.global(qos: DispatchQoS.QoSClass.background).asyncAfter(deadline: delta, execute: callback)
}
