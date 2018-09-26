//
//  LogViewController.swift
//  Time Tracer
//
//  Created by Celal Aslan on 2018-06-15.
//  Copyright © 2018 Celal Aslan. All rights reserved.
//

import UIKit
import CoreData

class LogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet var tableView: UITableView!
    
    /// fetch controller
    lazy var fetchController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
        let entity = NSEntityDescription.entity(forEntityName: "Logs", in: CoreDataHandler.sharedInstance.backgroundManagedObjectContext)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        
        let nameDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [nameDescriptor]
        
        let fetchedController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataHandler.sharedInstance.backgroundManagedObjectContext, sectionNameKeyPath: "duration", cacheName: nil)
        fetchedController.delegate = self as? NSFetchedResultsControllerDelegate
        return fetchedController
    }()
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LogList!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        
        let log = LogList![indexPath.row]
        cell.textLabel?.text = log.name
        cell.detailTextLabel?.text = "Duration : " + LogViewController.createDurationStringFromDuration(duration: (log.duration?.doubleValue)!)
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let log = LogList![indexPath.row]
            CoreDataHandler.sharedInstance.deleteObject(object: log)
            reloadCoreDataEntities()
            
        }
    }
    
    /**
     Called when user selected a cell, if in editing mode, mark the cell as selected
     
     - parameter tableView: tableView
     - parameter indexPath: indexPath that was selected
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing == true {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            updateDeleteButtonTitle()
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    /**
     Called when user deselects a cell. If editing, update the delete button's title
     
     - parameter tableView: tableView
     - parameter indexPath: cell at the indexPath that was deselected
     */
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing == true {
            updateDeleteButtonTitle()
        }
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
     Returns the number of selected items.
     
     - returns: number of selected rows.
     */
    func numberOfItemsToDelete() -> NSInteger {
        if let selectedRows = tableView.indexPathsForSelectedRows {
            return selectedRows.count
        } else {
            return 0
        }
    }
    
    /**
     Update the Delete barbutton according to the number of selected objects.
     */
    func updateDeleteButtonTitle() {
        let itemsCountToDelete = numberOfItemsToDelete()
        navigationItem.leftBarButtonItem?.isEnabled = itemsCountToDelete != 0
        navigationItem.leftBarButtonItem?.title = "Delete (\(itemsCountToDelete))"
    }
    
    /**
     Put the tableView into an editing mode and load the editing state
     */
    @objc func editButtonPressed() {
        tableView.setEditing(true, animated: true)
        loadEditState()
    }
    
    /**
     Called when in edit mode the delete is pressed. Delete all the selected rows, if there are any.
     */
    @objc func deleteButtonPressed() {
        let itemsCountToDelete = numberOfItemsToDelete()
        if itemsCountToDelete != 0 {
            var objectsToDelete: [Logs] = []
            let selectedIndexPaths = tableView.indexPathsForSelectedRows
            for indexPath in selectedIndexPaths! {
                let history = fetchController.object(at: indexPath)
                objectsToDelete.append(history as! Logs)
            }
            
            CoreDataHandler.sharedInstance.deleteObjects(objectsToDelete: objectsToDelete)
            updateDeleteButtonTitle()
            
            if fetchController.fetchedObjects?.count == 0 {
                loadNormalState()
                reloadCoreDataEntities()
            }
        }
    }
    
    /**
     Stop editing of the tableView, and load the normal state
     */
    @objc func doneButtonPressed() {
        tableView.setEditing(false, animated: true)
        loadNormalState()
    }
    
    /**
     Pop the viewController
     */
    @objc func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    
    func refreshView() {
        tableView.reloadData()
    }
    
    /**
     Load activity entities from core data.
     */
    func reloadCoreDataEntities() {
        LogList = CoreDataHandler.sharedInstance.allLogItems()
        refreshView()
    }
    
    /**
     Creates a duration string from the passed in duration value. Format is 00:00:00
     
     - parameter duration: duration to value to use for displaying the duration
     
     - returns: NSString formatted duration string
     */
    class func createDurationStringFromDuration(duration: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 2
        
        let seconds = UInt8(Int(duration) % 60)
        let minutes = UInt8((Int(duration) / 60) % 60)
        let hours = UInt8((duration / 3600))
        
        let secondString = seconds > 9 ? String(seconds) : "0" + String(seconds)
        let minuteString = minutes > 9 ? String(minutes) : "0" + String(minutes)
        let hoursString = hours > 9 ? String(hours) : "0" + String(hours)
        
        let durationString = "\(hoursString):\(minuteString):\(secondString)"
        return durationString
    }
    
    /**
     Creates a string from the passed in integer
     - parameter time: integer to use for creating the time string
     */
    func timeStringWithTimeToDisplay(time: Int) -> String {
        return String(format: "%.2d", time)
    }
    
    /**
     Load the normal state of the navigation bar
     */
    func loadNormalState() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.backBarButtonItem?.action = #selector(LogViewController.backButtonPressed)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(LogViewController.editButtonPressed))
    }
    
    /**
     Load the editing state of the navigation bar
     */
    func loadEditState() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(LogViewController.deleteButtonPressed))
        
        if numberOfItemsToDelete() == 0 {
            navigationItem.leftBarButtonItem?.isEnabled = false
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(LogViewController.doneButtonPressed))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        title = "Task Log"
        reloadCoreDataEntities()
        refreshView()
        tableView.reloadData()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadCoreDataEntities()
    }
}
