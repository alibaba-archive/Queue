# Queue
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

a task queue with local persistent by Swift 2.0

#Overview

Queue is a subclass of NSOperationQueue so you get:

Serial or concurrent queues
Task priority
Multiple queues
Dependencies
Task persistence (via protocol)
Retries (exponential back-off)

#Motivation

With a good queuing solution you can provide a much better user experience in areas such as:

Web requests
Saving/creating content (images, video, audio)
Uploading data

The actual code to perform the task gets passed to the queue in the form of a taskHandler closure. Each QueueTask must have a taskType key which corresponds to a specific taskCallback.

#Example Code

For a thorough example see the demo project in the top level of the repository.

##Create a queue

```
let queue = Queue(queueName: "NetWorking", maxConcurrency: 1, maxRetries: 3, serializationProvider: NSUserDefaultsSerializer(),logProvider: ConsoleLogger())
```
##Create a task

```
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
```
