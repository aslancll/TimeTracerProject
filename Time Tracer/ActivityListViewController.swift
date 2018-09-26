//
//  ActivityListViewController.swift
//  Time Tracer
//
//  Created by Celal Aslan on 2018-06-15.
//  Copyright © 2018 Celal Aslan. All rights reserved.
//

import UIKit

class ActivityListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var activityListTableView: UITableView!
    
    
    // MARK: tableView methods
    /**
     Tells the data source to return the number of rows in a given section of a table view. (required)
     
     - parameter tableView: tableView
     - parameter section:   at which section
     
     - returns: number of rows
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityList!.count
    }
    
    /**
     Asks the data source for a cell to insert in a particular location of the table view.
     
     - parameter tableView: tableView
     - parameter indexPath: at which indexPath
     
     - returns: configured cell
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell")!

        let activity = activityList![indexPath.row]
        cell.textLabel?.text = activity.name
        cell.textLabel?.textColor = UIColor.black
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    /**
     Returns YES, if you are allowed to edit rows
     
     - parameter tableView: tableView
     - parameter indexPath: at which indexPath
     
     - returns: YES, if allowed
     */
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /**
     Handle editing style
     
     - parameter tableView:    tableView
     - parameter editingStyle: which editing style happened
     - parameter indexPath:    at which cell
     */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let activity = activityList![indexPath.row]
            CoreDataHandler.sharedInstance.deleteObject(object: activity)
            reloadCoreDataEntities()
            
        }
    }
    
    /**
     Tells the delegate that the specified row is now selected. Pass the selected activity to the delegate method.
     
     - parameter tableView: tableView
     - parameter indexPath: which indexpath was selected
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "unwindFromActivities", sender: indexPath)
    }
    
    /**
     Height for each cell
     
     - parameter tableView: tableView
     - parameter indexPath: at which indexpath
     
     - returns: height
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    
    /**
     Returns the selected activity
     
     - returns: Activity that was selected
     */
    func selectedActivity() -> Activity {
        let selectedIndexPath = activityListTableView.indexPathForSelectedRow!
        return activityList![selectedIndexPath.row]
    }

    
    

    /**
     Refresh the view, reload the tableView and check if it's needed to show the empty view.
     */
    func refreshView() {
        activityListTableView.reloadData()
    }
    
    /**
     Load activity entities from core data.
     */
    func reloadCoreDataEntities() {
        activityList = CoreDataHandler.sharedInstance.fetchCoreDataAllActivities()
        refreshView()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityListTableView.delegate = self
        activityListTableView.dataSource = self
        title = "Task List"
        reloadCoreDataEntities()
        refreshView()
        activityListTableView.reloadData()
        
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadCoreDataEntities()
    }
}
