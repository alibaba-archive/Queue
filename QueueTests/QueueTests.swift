//
//  QueueTests.swift
//  QueueTests
//
//  Created by ChenHao on 12/10/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

import XCTest
@testable import Queue

// swiftlint:disable line_length

class QueueTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testExample() {
        let queue = Queue(queueName: "NetWorking", maxConcurrency: 1, maxRetries: 5, serializationProvider: NSUserDefaultsSerializer(), logProvider: ConsoleLogger(), completeClosure: nil)

        if queue.hasUnfinishedTask() {
            print("存在未完成任务")
        } else {
            print("不存在未完成任务")
        }

        queue.loadSerializeTaskToQueue()
        for _ in 0..<100 {
            queue.addTaskCallback("Create") { (task) -> Void in

                task.complete(nil)
            }

            queue.addTaskCallback("Delete") { (task) -> Void in

                task.complete(NSError(domain: "dsfs", code: 22, userInfo: nil))
            }

            queue.addTaskCallback("Update") { (task) -> Void in
                task.complete(nil)
            }

            queue.addTaskCallback("Select") { (task) -> Void in
                task.complete(nil)
            }

            let task = QueueTask(queue: queue, type: "Create", userInfo: nil, retries: 3)
            let taskDelete = QueueTask(queue: queue, type: "Delete", userInfo: nil, retries: 3)
            queue.addOperation(taskDelete)
            queue.addOperation(task)
        }

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
