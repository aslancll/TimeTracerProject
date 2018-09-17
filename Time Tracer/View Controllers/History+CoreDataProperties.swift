//
//  History+CoreDataProperties.swift
//  Time Tracer
//
//  Created by Celal Aslan on 2018-06-19.
//  Copyright © 2018 Celal Aslan. All rights reserved.
//

import Foundation
import CoreData

extension History {
    
    /// time when the activity was saved for later sorting
    @NSManaged var saveTime: String?
    /// start date of history
    @NSManaged var startDate: NSDate?
    /// name of history
    @NSManaged var name: String?
    /// end date of history
    @NSManaged var endDate: NSDate?
    /// duration of the activity
    @NSManaged var duration: NSNumber?
    
}

