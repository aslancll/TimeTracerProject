//
//  NewActivityViewController.swift
//  Time Tracer
//
//  Created by Celal Aslan on 2018-06-15.
//  Copyright © 2018 Celal Aslan. All rights reserved.
//

import UIKit

class NewActivityViewController: UIViewController {

    @IBOutlet weak var newActivityTextField: UITextField!
    
    @IBAction func addPressed(_ sender: Any) {
        
        let activityName = newActivityTextField.text
        if activityName?.count == 0 {
            newActivityTextField.text = ""
        } else {
            if CoreDataHandler.sharedInstance.isDuplicate(activityName: activityName!) == true {
//                let alertView = UIAlertController(title: "Duplicate", message: "This activity is already in your activity list.", preferredStyle: .alert)
//                                let alertView = UIAlertView(title: "Duplicate", message: "This activity is already in your activity list.", delegate: nil, cancelButtonTitle: "Ok")
                let alertView = UIAlertController(title: "Duplicate", message: "This activity is already in your activity list.", preferredStyle: .alert)
                alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertView, animated: true, completion: nil)
            } else {
                CoreDataHandler.sharedInstance.addNewActivityName(name: activityName!)
                newActivityTextField.text = ""
            }
        }
        
    }
//
//        if (newActivityTextField.text != nil) && newActivityTextField.text != nil  {
//            activityList?.append(newActivityTextField.text!)
//            newActivityTextField.text = ""
//            newActivityTextField.placeholder = "Will you add more activity ?"
//        }
//


    override func viewDidLoad() {
        super.viewDidLoad()
        newActivityTextField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
}
    /**
     Asks the delegate if the text field should process the pressing of the return button. Animate the view back up and save the item to core data if possible.
     - param textField The text field whose return button was pressed.
     - return BOOL YES if the text field should implement its default behavior for the return button; otherwise, NO.
     */

