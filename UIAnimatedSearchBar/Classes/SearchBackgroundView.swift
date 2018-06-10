//
//  SearchBackgroundView.swift
//  QuickTest
//
//  Created by Kyle Burkholder on 6/1/18.
//  Copyright © 2018 Kyle Burkholder. All rights reserved.
//

import UIKit

class SearchBackgroundView: UIView
{

    var color: UIColor
    {
        didSet
        {
            setNeedsDisplay()
        }
    }
    
    convenience init(color: UIColor)
    {
        self.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.color = color
    }
    
    override init(frame: CGRect)
    {
        color = .black
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect)
    {
        let roundedBackground = UIBezierPath(roundedRect: bounds, cornerRadius: 10.0)
        color.setFill()
        roundedBackground.fill()
    }
 

}
