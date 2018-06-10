//
//  ViewController.swift
//  UIAnimatedSearchBar
//
//  Created by KyleBurkholder on 06/10/2018.
//  Copyright (c) 2018 KyleBurkholder. All rights reserved.
//

import UIKit
import UIAnimatedSearchBar

class ViewController: UIViewController
{
    
    @IBOutlet weak var animatedSearchBar: UIAnimatedSearchBar!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        animatedSearchBar.showBookmarkButton = true
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        animatedSearchBar.setShowsCancelButton(true, animated: true)
    }

}

