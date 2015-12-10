//
//  ViewController.swift
//  QueueDemo
//
//  Created by ChenHao on 12/10/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

import UIKit
import Queue

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let queue = Queue(queueName: "", maxConcurrency: 1, maxRetries: 3, serializationProvider: nil, logProvider: ConsoleLogger())
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
        
        let task = QueueTask(queue: queue, type: "Create", userInfo: nil, retries: 3)
        let taskDelete = QueueTask(queue: queue, type: "Delete", userInfo: nil, retries: 3)
        queue.addOperation(taskDelete)
        queue.addOperation(task)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

