//
//  NewActivityVie.swift
//  Time Tracer
//
//  Created by Celal Aslan on 2018-06-19.
//  Copyright © 2018 Celal Aslan. All rights reserved.
//

import Foundation


/**
 Delegate protocol.
 */
protocol NewActivityDelegate {
    /**
     Delegate method to tell the view controller that an activity has been saved.
     */
    func slideActivityViewUp()
}

/**
 A view to add new activities.
 */

class NewActivityView: UIView, UITextFieldDelegate {
    
    var textField: ActivityTextfield = ActivityTextfield()
    
    var delegate: NewActivityDelegate?
    
    /**
     Custom initaliser
     
     - parameter frame:    frame
     - parameter delegate: delegate
     
     - returns: self
     */
    init(frame: CGRect, delegate: NewActivityDelegate) {
        let label = UILabel()
        label.frame = CGRect(x: 10.0, y: 10.0, width: (frame.size.width)-20.0, height: 40.0)
        label.text = "Enter the name of your activity"
        label.textColor = UIColor.cellBackgroundColor()
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.numberOfLines = 0
        
        self.textField = ActivityTextfield()
        self.textField.frame = CGRect(x: 10.0, y: (frame.size.height) - 40.0, width: (frame.size.width), height: 30.0)
        
        self.delegate = delegate
        super.init(frame: frame)
        
        self.textField.delegate = self
        self.addSubview(self.textField)
        self.addSubview(label)
        
        backgroundColor = UIColor.activityViewBackgroundColor()
        layer.cornerRadius = 2.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     Save an activity to core data if it is not already in the core data or not null.
     */
    func saveItem() {
        let activityName = textField.text
        if activityName?.count == 0 {
            textField.text = ""
            slideViewUp()
        } else {
            if CoreDataHandler.sharedInstance.isDuplicate(activityName: activityName!) == true {
                let alertView = UIAlertView(title: "Duplicate", message: "This activity is already in your activity list.", delegate: nil, cancelButtonTitle: "Ok")
                alertView.show()
            } else {
                CoreDataHandler.sharedInstance.addNewActivityName(name: activityName!)
                
                textField.text = ""
                slideViewUp()
                delegate?.slideActivityViewUp()
            }
        }
    }
    
    /**
     Slide the view down with animation and make the textfield active.
     */
    func slideViewDown() {
        var frame = self.frame
        frame.origin.y = -10
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.frame = frame
        }) { (finished) -> Void in
            self.textField.becomeFirstResponder()
        }
    }
    
    /**
     Slide the view up with animation and make the textfield inactive.
     */
    func slideViewUp() {
        var frame = self.frame
        frame.origin.y = -100
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.frame = frame
        }) { (finished) -> Void in
            self.textField.resignFirstResponder()
        }
    }
    
    /**
     Asks the delegate if the text field should process the pressing of the return button. Animate the view back up and save the item to core data if possible.
     - param textField The text field whose return button was pressed.
     - return BOOL YES if the text field should implement its default behavior for the return button; otherwise, NO.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveItem()
        return true
    }
    
}
