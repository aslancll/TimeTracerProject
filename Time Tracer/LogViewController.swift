//
//  SecondViewController.swift
//  Time Tracer
//
//  Created by Celal Aslan on 2018-06-15.
//  Copyright © 2018 Celal Aslan. All rights reserved.
//

import UIKit
import CoreData
class LogViewController: UIViewController {

    /// table view to display items
    @IBOutlet weak var tableView: UITableView!
    /// A label to display when there are no items in the view
    @IBOutlet weak var noItemsLabel: UILabel!
    
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
    
    /// date formatter
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter
    }()
    
    // MARK: view methods
    /**
     Called after the view was loaded, do some initial setup and refresh the view
     */
    override func viewDidLoad() {
        title = "Week Log"
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
//        tableView.separatorColor = UIColor.tableViewSeparatorColor()
//        tableView.backgroundColor = UIColor.tableViewBackgroundColor()
        
        refreshView()
        loadNormalState()
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
    
    /**
     Refresh the view, reload the tableView and check if it's needed to show the empty view.
     */
    func refreshView() {
        loadCoreDataEntities()
//        checkToShowEmptyLabel()
    }
    
    /**
     Checks for the available Activities, if YES show the empty view
     */
//    func checkToShowEmptyLabel() {
//        noItemsLabel.isHidden = fetchController.fetchedObjects?.count != 0
//        tableView.reloadData()
//    }
    
    /**
     Load history entities from core data.
     */
    func loadCoreDataEntities() {
        do {
            try fetchController.performFetch()
        } catch {
            // error occured while fetching
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
//            checkToShowEmptyLabel()
            updateDeleteButtonTitle()
            
            if fetchController.fetchedObjects?.count == 0 {
                loadNormalState()
                                loadCoreDataEntities()
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
    
    // MARK: tableView methods
    /**
     Notifies the receiver that the fetched results controller is about to start processing of one or more changes due to an add, remove, move, or update.
     
     - parameter controller: controller The fetched results controller that sent the message.
     */
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    /**
     Notifies the receiver that a fetched object has been changed due to an add, remove, move, or update. The fetched results controller reports changes to its section before changes to the fetch result objects.
     
     - parameter controller:   The fetched results controller that sent the message.
     - parameter anObject:     The object that was changed
     - parameter indexPath:    at which indexPath
     - parameter type:         what happened
     - parameter newIndexPath: The destination path for the object for insertions or moves (this value is nil for a deletion).
     */
    private func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeObject anObject: Any, atIndexPath indexPath: IndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case NSFetchedResultsChangeType.insert:
            tableView.insertRows(at: [indexPath! as IndexPath], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath! as IndexPath], with: .left)
            break
        case .update:
            configureCell(cell: tableView.cellForRow(at: indexPath! as IndexPath) as! LogCell, indexPath: indexPath! as NSIndexPath as NSIndexPath)
            break
        case .move:
            tableView.deleteRows(at: [indexPath! as IndexPath], with: .left)
            tableView.insertRows(at: [newIndexPath! as IndexPath], with: .fade)
            break
        }
    }
    
    /**
     Notifies the receiver of the addition or removal of a section. The fetched results controller reports changes to its section before changes to the fetched result objects.
     
     - parameter controller:   The fetched results controller that sent the message.
     - parameter sectionInfo:  section that was changed
     - parameter sectionIndex: the index of the section
     - parameter type:         what happened
     */
    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch(type)
        {
        case .insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
            break
        case .delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .left)
            break
        case .update:
            break
        default:
            break
        }
    }
    
    /**
     Notifies the receiver that the fetched results controller has completed processing of one or more changes due to an add, remove, move, or update.
     
     - parameter controller: controller The fetched results controller that sent the message.
     */
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    /**
     Returns the height value for the given indexPath
     
     - parameter tableView: tableView
     - parameter indexPath: at which indexpath
     
     - returns: height for a row
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    /**
     Return the number of rows to display at a given section
     
     - parameter tableView: tableView
     - parameter section:   at which section
     
     - returns: number of rows
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        } else {
            return 0
        }
    }
    
    /**
     Returns the number of sections to display
     
     - parameter tableView: tableView
     - returns: number of sections to display
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchController.sections {
            return sections.count
        } else {
            return 0
        }
    }
    
    /**
     Asks the delegate for the height to use for the header of a particular section.
     
     - parameter tableView: tableView
     - parameter section:   section
     
     - returns: height of a header
     */
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    /**
     Title for the header in a given section
     
     - parameter tableView: tableView
     - parameter section:   section
     
     - returns: title of the header
     */
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchController.sections {
            return sections[section].name
        } else {
            return ""
        }
    }
    
    /**
     Returns a custom header view to be displayed at a section
     
     - parameter tableView: tableView
     - parameter section:   section
     
     - returns: headerView
     */
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let title = self.tableView(tableView, titleForHeaderInSection: section)
//        let heightForView = self.tableView(tableView, heightForHeaderInSection: section)
//        let headerView = HeaderView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: heightForView), title: title! as NSString)
//        return headerView
//    }
    
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
     Configures and returns a cell for the given indexpath
     
     - parameter tableView: tableView
     - parameter indexPath: indexPath
     
     - returns: cell
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! LogCell
        
        configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
        
        return cell
    }
    
    /**
     Configures a cell at the given indexPath
     
     - parameter cell:      cell to configure
     - parameter indexPath: indexPath
     */
    func configureCell(cell: LogCell, indexPath: NSIndexPath) {
        let log = fetchController.object(at: indexPath as IndexPath) as! Logs
        
        cell.nameLabel.text = log.name
//        cell.timeLabel.text = "\(dateFormatter.string(from: history.startDate! as Date)) -  \(dateFormatter.string(from: history.endDate! as Date))"
        cell.durationLabel.text = LogViewController.createDurationStringFromDuration(duration: (log.duration?.doubleValue)!)
        
//        cell.backgroundColor = .cellBackgroundColor()
    }
    
    /**
     Return YES/True to allow editing of cells
     
     - parameter tableView: tableView
     - parameter indexPath: at which indexPath
     
     - returns: true if editing allowed
     */
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /**
     Called when an editing happened to the cell, in this case: delete. So delete the object from core data.
     
     - parameter tableView:    tableView
     - parameter editingStyle: the editing style, in this case Delete is important
     - parameter indexPath:    at which indexpath
     */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let logToDelete = fetchController.object(at: indexPath)
            CoreDataHandler.sharedInstance.deleteObject(object: logToDelete as! NSManagedObject)
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
    
}

    
    
    class LogCell: UITableViewCell {
        
        
        /// display the name of the history item
        @IBOutlet weak var nameLabel: UILabel!
        /// display the duration of the history item
        @IBOutlet weak var durationLabel: UILabel!
        
        
        /**
         Customize the look of the cell
         */
        override func awakeFromNib() {
            super.awakeFromNib()
            
            nameLabel.textColor = UIColor.green
            durationLabel.textColor = UIColor.red
            backgroundColor = UIColor.white
        }
        
        /**
         Toggles the receiver into and out of editing mode. When YES, hide the durationLabel with animation.
         
         - parameter editing:  YES to enter editing mode, NO to leave it. The default value is NO
         - parameter animated: YES to animate the appearance or disappearance of the insertion/deletion control and the reordering control, NO to make the transition immediate.
         */
        override func setEditing(_ editing: Bool, animated: Bool) {
            super.setEditing(editing, animated: animated)
            if editing == true {
                durationLabel.alpha = 0
            } else {
                durationLabel.alpha = 1
            }
        }
        
    }
