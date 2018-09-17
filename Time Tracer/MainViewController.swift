//
//  FirstViewController.swift
//  Time Tracer
//
//  Created by Celal Aslan on 2018-06-15.
//  Copyright © 2018 Celal Aslan. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    
    /// boolean value to determine whether an activity is running
    var isActivityRunning: Bool = false
    /// boolean value to determine whether an activity is paused
    var isActivityPaused: Bool = false
    /// passed seconds from start
    var passedSeconds: Int = 0
    
    /// the choosen activity object to use
    var choosenActivity: Activity?
    
    /// date of start
//    var startDate: NSDate!
    /// date of quitting the app
//    var quitDate: NSDate?
    
    /// timer that counts the seconds
    var activityTimer: Timer?
    /// total number of seconds for log objects
    var totalduration: NSInteger = 0
    
    // array of all the activities (log objects) that happened today
    var todaysActivitiesArray: [Logs] = []
    
    /// today's date formatter
    lazy var todayDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd"
        return dateFormatter
    }()
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startPauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var currentDateField: UITextField!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    
    /**
     Called when view has finished loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        currentDateField.becomeFirstResponder()
        currentDateField.delegate = self
        title = "Time Tracer"
        activityLabel.text = "Select an activity from list"
        
    }
    
    /**
     Called when the view appeared. Load the core data entities for today
     - param: animated YES if animated
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadCoreDataEntities()
    }

    func dateTapped() {
        
        DatePickerDialog().show("DatePicker", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) {
            (date) -> Void in
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            self.currentDateField.text = dateFormatter.string(from: date!)
        }
    }
    
    /**
     Called when user selected an activity on ActivityListViewController. First it checks to see if any activities are running, if YES it stops the current one, and runs the new
     
     - parameter unwindSegue: the unwind segue
     */
    @IBAction func unwindFromActivitiesView(unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source as! ActivityListViewController
        
        let selectedActivity = sourceViewController.selectedActivity()
        if choosenActivity != selectedActivity {
            stopActivity()
            choosenActivity = selectedActivity
            startActivity()
        }
    }
    
    /**
     IBAction method to handle the start and pause button's press action.
     */
    @IBAction func startPauseActivity() {
        if isActivityRunning == true {
            pauseActivity()
        } else {
            if isActivityPaused == true {
                isActivityPaused = false
                isActivityRunning = true
                startPauseButton.setTitle("Pause Activity", for: [])
                startActivityTimer()
            }
        }
    }
    
    /**
     Stop the activity and save it to core data.
     */
    @IBAction func stopActivity() {
        invalidateTimer()
        isActivityRunning = false
        isActivityPaused = false
        secondsLabel.text = "00"
        minutesLabel.text = "00"
        hoursLabel.text = "00"
        activityLabel.text = "Select an activity from list"
        startPauseButton.setTitle("Start activity", for: [])
        if passedSeconds != 0 {
            saveActivityToLog()
            tableView.reloadData()
        }
    }
    
    /**
     Start the new activity. start timer and set properties.
     */
    func startActivity() {
//        startDate = NSDate()
        passedSeconds = 0
        invalidateTimer()
        startActivityTimer()
        startPauseButton.setTitle("Pause Activity", for: [])
        isActivityRunning = true
        isActivityPaused = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        activityLabel.text = "\(choosenActivity!.name!) is started!"
    }
    
    /**
     Pause the activity.
     */
    func pauseActivity() {
        isActivityPaused = true
        isActivityRunning = false
        invalidateTimer()
        startPauseButton.setTitle("Resume Activity", for: [])
    }
    
    func startActivityTimer() {
        activityTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MainViewController.updateLabel), userInfo: nil, repeats: true)
    }
    
    /**
     Save the finished activity to core data as a history object.
     */
    func saveActivityToLog() {
        CoreDataHandler.sharedInstance.saveLog(name: choosenActivity!.name!, duration: passedSeconds)
        
        passedSeconds = 0
        choosenActivity = nil
        loadCoreDataEntities()
    }
    
    /**
     Stop the timer
     */
    func invalidateTimer() {
        if let timer = activityTimer {
            timer.invalidate()
        }
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
     Update labels every time the timer's method called.
     */
    @objc func updateLabel() {
        passedSeconds = passedSeconds + 1
        
        let seconds = passedSeconds % 60
        let minutes = (passedSeconds / 60) % 60
        let hours = passedSeconds / 3600
        
        secondsLabel.text = timeStringWithTimeToDisplay(time: seconds)
        minutesLabel.text = timeStringWithTimeToDisplay(time: minutes)
        hoursLabel.text = timeStringWithTimeToDisplay(time: hours)
        print(passedSeconds)
    }

    /**
     Load history entities from core data.
     */
    func loadCoreDataEntities() {
        todaysActivitiesArray = CoreDataHandler.sharedInstance.fetchCoreDataForTodayActivities()
        if todaysActivitiesArray.count != 0 {
            totalduration = calculateTotalDurationForToday()
        }
        tableView.reloadData()
        print("data reloaded")
    }
    
    /**
     Calculate the total duration of activites for today.
     
     - returns: NSInteger summary value of durations as an integer.
     */
    func calculateTotalDurationForToday() -> NSInteger {
        var sumOfDuration = 0
        for history in todaysActivitiesArray {
            sumOfDuration += (history.duration?.intValue)!
        }
        return sumOfDuration
    }
    
    
    // MARK: tableView methods
    /**
     Asks the data source for a cell to insert in a particular location of the table view.

     - parameter tableView: tableView
     - parameter indexPath: indexPath

     - returns: created cell
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! LogCell

        let log = todaysActivitiesArray[indexPath.row]

        cell.durationLabel.text = MainViewController.createDurationStringFromDuration(duration: (log.duration?.doubleValue)!)

        return cell
    }

    /**
     How many rows/cells to display

     - parameter tableView: tableView
     - parameter section:   in which section

     - returns: number of rows
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todaysActivitiesArray.count
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
     Height for the headerview

     - parameter tableView: tableView
     - parameter section:   at which section

     - returns: height
     */
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    /**
     What view to use for each section

     - parameter tableView: tableView
     - parameter section:   at which section

     - returns: headerView
     */
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let title = self.tableView(tableView, titleForHeaderInSection: section)
//        let heightForRow = self.tableView(tableView, heightForHeaderInSection: section)
//                let cgFloat: CGFloat = tableView.frame.size.width
//        let headerView = HeaderView(frame: CGRect.init(x: 0.0, y: 0.0, width: (tableView.frame.size.width) , height: heightForRow), title: title! as NSString)
//        return headerView
//    }

    /**
     What the title should be

     - parameter tableView: tableView
     - parameter section:   at which section

     - returns: title
     */
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return String(format: "Total spent today: \(NSString.createDurationStringFromDuration(duration: Double(totalduration)))")
//    }



}

extension MainViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == currentDateField {
            dateTapped()
            return false
        }
        return true
    }
}


//func configureTapGesture() {
//    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap))
//    view.addGestureRecognizer(tapGesture)
//}
//
//@objc func handleTap() {
//    print("handleTap method was called")
//    view.endEditing(true)
//}

