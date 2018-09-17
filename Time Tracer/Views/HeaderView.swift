//
//  HeaderView.swift
//  Time Tracer
//
//  Created by Celal Aslan on 2018-06-19.
//  Copyright © 2018 Celal Aslan. All rights reserved.
//

import Foundation


/**
 Custom view for the tableView headers
 */

class HeaderView: UIView {
    
    /**
     Initializes the view with given frame and title
     
     - parameter frame: frame to use
     - parameter title: title to set
     
     - returns: self
     */
    init(frame: CGRect, title: NSString) {
        super.init(frame: frame)
        addSubview(createLabelWithFrame(frame: frame, title: title))
        backgroundColor = UIColor.tableViewHeaderViewBackgroundColor()
    }
    
    /**
     Init
     
     - parameter aDecoder: decoder
     
     - returns: self
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     Creates a label with given frame and title
     
     - parameter frame: frame to use
     - parameter title: title to set
     
     - returns: created label
     */
    func createLabelWithFrame(frame: CGRect, title: NSString) -> UILabel {
        let titleLabel = UILabel(frame: frame)
        titleLabel.text = title as String
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.systemFont(ofSize:15.0)
        
        return titleLabel
    }
    
}
