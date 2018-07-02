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
    @IBOutlet var animatedSearchBar: UIAnimatedSearchBar!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        animatedSearchBar.delegate = self
    }
    
    
    
    override func viewDidAppear(_ animated: Bool)
    {
        
    }
    
    var searchBarTextDidChangeWasCalled = false
    var searchBarShouldChangeTextInWasCalled = false
    var searchBarShouldBeginEditingWasCalled = false
    var searchBarDidBeginEditingWasCalled = false
    var searchBarShouldEndEditingWasCalled = false
    var searchBarDidEndEditingWasCalled = false
    var searchBarBookmarkButtonClickedWasCalled = false
    var searchBarCancelButtonClickedWasCalled = false
    var searchBarSearchButtonClickedWasCalled = false
}

extension ViewController: UIAnimatedSearchBarDelegate
{
    func searchBar(_ searchBar: UIAnimatedSearchBar, textDidChange searchText: String)
    {
        searchBarTextDidChangeWasCalled = true
        print("TextDidChange")
    }
    
    func searchBar(_ searchBar: UIAnimatedSearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        searchBarShouldChangeTextInWasCalled = true
        print("shouldChangeTextIn \(text)")
        return true
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UIAnimatedSearchBar) -> Bool
    {
        searchBarShouldBeginEditingWasCalled = true
        print("TextShouldBeginEditing")
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UIAnimatedSearchBar)
    {
        searchBarDidBeginEditingWasCalled = true
        print("TextDidBeginEditing")
    }
    
    func searchBarShouldEndEditing(_ searchBar: UIAnimatedSearchBar) -> Bool
    {
        searchBarShouldEndEditingWasCalled = true
        print("TextShouldEndEditing")
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UIAnimatedSearchBar)
    {
        searchBarDidEndEditingWasCalled = true
        print("TextDidEndEditing")
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UIAnimatedSearchBar)
    {
        searchBarBookmarkButtonClickedWasCalled = true
        print("BookmarkButtonClicked")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UIAnimatedSearchBar)
    {
        searchBarCancelButtonClickedWasCalled = true
        print("CancelButtonClicked")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UIAnimatedSearchBar)
    {
        searchBarSearchButtonClickedWasCalled = true
        print("SearchButtonClicked")
    }
}

