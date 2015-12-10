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
        let queue = Queue(queueName: "BackgroundQueue")
        queue.addTaskCallback("Create") { (task) -> Bool in
            print("Create")
            return true
        }
        
        queue.addTaskCallback("Delete") { (task) -> Bool in
            print("Delete")
            return false
        }
        
        queue.addTaskCallback("Update") { (task) -> Bool in
            return true
        }
        
        queue.addTaskCallback("Select") { (task) -> Bool in
            return true
        }
        
        
        let task = QueueTask(queue: queue, type: "Create", data: nil, retries: 3)
        let taskDelete = QueueTask(queue: queue, type: "Delete", data: nil, retries: 3)
        queue.addOperation(taskDelete)
        queue.addOperation(task)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

