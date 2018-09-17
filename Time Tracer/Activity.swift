//
//  Activity.swift
//  Time Tracer
//
//  Created by Celal Aslan on 2018-06-15.
//  Copyright © 2018 Celal Aslan. All rights reserved.
//

import Foundation
import CoreData

class Activity: NSManagedObject {

    /// name of activity
    @NSManaged var name: String?
    
    /// duration of the activity
    @NSManaged var duration: NSNumber?
}


var activityList: [Activity]?

func saveData (activityList:[Activity]) {
    UserDefaults.standard.set(activityList, forKey: "activityList")
}

func fetchData() -> [Activity]? {
    
    if let activity = UserDefaults.standard.array(forKey: "activityList") as? [Activity] {
        return activity
    } else {
        return nil
    }
}


