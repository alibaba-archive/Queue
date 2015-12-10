//
//  QueueTests.swift
//  QueueTests
//
//  Created by ChenHao on 12/10/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

import XCTest
@testable import Queue

class QueueTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let queue = Queue(queueName: "BackgroundQueue")
        queue.addTaskCallback("Create") { (task) -> Void in
            print("Create")
            task.complete(nil)
        }
        
        queue.addTaskCallback("Delete") { (task) -> Void in
            
            task.complete(nil)
        }
        
        queue.addTaskCallback("Update") { (task) -> Void in
            
        }
        
        queue.addTaskCallback("Select") { (task) -> Void in
            
        }
        
        let task = QueueTask(queue: queue, type: "Create", data: nil, retries: 3)
        let taskDelete = QueueTask(queue: queue, type: "Delete", data: nil, retries: 3)
        queue.addOperation(taskDelete)
        queue.addOperation(task)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
