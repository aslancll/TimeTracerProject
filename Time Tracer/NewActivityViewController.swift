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
                let alertView = UIAlertController(title: "Duplicate", message: "This task is already in your activity list.", preferredStyle: .alert)
                alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertView, animated: true, completion: nil)
            } else {
                CoreDataHandler.sharedInstance.addNewActivityName(name: activityName!)
                newActivityTextField.text = ""
            }
        }
        
    }

    func addBackground() {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRect(x:0, y:0, width: width, height: height))
        imageViewBackground.image = UIImage(named: "bg.png")
        imageViewBackground.contentMode = UIViewContentMode.scaleAspectFill
        
        self.view.addSubview(imageViewBackground)
        self.view.sendSubview(toBack: imageViewBackground)
    }
    func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        newActivityTextField.becomeFirstResponder()
        title = "New Task"
        addBackground()
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        // Do any additional setup after loading the view.
    }
    
}

