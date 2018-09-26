//
//  Logs.swift
//  Time Tracer
//
//  Created by Celal on 2018-09-15.
//  Copyright © 2018 Celal Aslan. All rights reserved.
//

import Foundation
import CoreData

class Logs: NSManagedObject {
    
    /// name of activity
    @NSManaged var name: String?
    
    /// duration of the activity
    @NSManaged var duration: NSNumber?
}

var LogList: [Logs]?

func saveLogData (LogList:[Logs]) {
    UserDefaults.standard.set(LogList, forKey: "LogList")
}

func fetchLogData() -> [Logs]? {
    
    if let log = UserDefaults.standard.array(forKey: "LogList") as? [Logs] {
        return log
    } else {
        return nil
    }
}
