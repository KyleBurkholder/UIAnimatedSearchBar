//
//  UIAnimatedSearchBar.swift
//  QuickTest
//
//  Created by Kyle Burkholder on 6/1/18.
//  Copyright © 2018 Kyle Burkholder. All rights reserved.
//

import UIKit

@objc public protocol UIAnimatedSearchBarDelegate
{
    @objc optional func searchBar(_ searchBar: UIAnimatedSearchBar, textDidChange searchText: String)

    @objc optional func searchBar(_ searchBar: UIAnimatedSearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    
    @objc optional func searchBarShouldBeginEditing(_ searchBar: UIAnimatedSearchBar) -> Bool

    @objc optional func searchBarTextDidBeginEditing(_ searchBar: UIAnimatedSearchBar)

    @objc optional func searchBarShouldEndEditing(_ searchBar: UIAnimatedSearchBar) -> Bool

    @objc optional func searchBarTextDidEndEditing(_ searchBar: UIAnimatedSearchBar)

    @objc optional func searchBarBookmarkButtonClicked(_ searchBar: UIAnimatedSearchBar)

    @objc optional func searchBarCancelButtonClicked(_ searchBar: UIAnimatedSearchBar)

    @objc optional func searchBarSearchButtonClicked(_ searchBar: UIAnimatedSearchBar)

    //@objc optional func searchBarResultsListButtonClicked(_ searchBar: UIAnimatedSearchBar)

    //@objc optional func searchBar(_ searchBar: UIAnimatedSearchBar, selectedScopeButtonIndexDidChange selectedScope: Int)
}


@IBDesignable
public class UIAnimatedSearchBar: UIView
{
    //MARK: Exposed Properties
    public weak var delegate: UIAnimatedSearchBarDelegate?
    
    public var placeholder: String?
    {
        get
        {
            return searchTextField.placeholder
        }
        set
        {
            searchTextField.placeholder = newValue
        }
    }
    
    public var text: String?
    {
        get
        {
            return searchTextField.text
        }
        set
        {
            searchTextField.text = newValue
        }
    }

    public var barTintColor: UIColor = Constants.defaultBackgroundColor
    {
        didSet
        {
            searchWindow.color = barTintColor
        }
    }
    
    override public var tintColor: UIColor!
    {
        didSet
        {
            let darkTintColor = tintColor.withAlphaComponent(0.95)
            animatedIcon.color = darkTintColor
            searchTextField.tintColor = darkTintColor
            cancelButton?.tintColor = darkTintColor
        }
    }

    public var showBookmarkButton: Bool
    {
        get
        {
            return searchTextField.rightView != nil
        }
        
        set
        {
            if newValue
            {
                let animatedSearchBarBundle = Bundle(for: UIAnimatedSearchBar.self)
                print(animatedSearchBarBundle)
                let button = UIButton(type: UIButton.ButtonType.system)
                button.frame = CGRect(x: 0, y: 0, width: 21, height: 21)
                let image = UIImage(named: "bookmarkIcon", in: animatedSearchBarBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                button.setImage(image, for: .normal)
                button.addTarget(self, action: #selector(bookmarkButtonClicked), for: UIControl.Event.touchUpInside)
                searchTextField.rightView = button
            } else
            {
                searchTextField.rightView = nil
            }
        }
    }
    
    public var bookmarkButton: UIButton?
    {
        return searchTextField.rightView as? UIButton
    }
    
    public var showsCancelButton: Bool
    {
        get {
            return cancelButtonIsVisible
        }
        set {
            setShowsCancelButton(newValue, animated: false)
        }
    }
    
    public var cancelButton: UIButton?
    
    public var animationSpeed: Double?
    {
        didSet
        {
            animatedIcon.animationSpeed = animationSpeed! / 2.0
        }
    }
    
    override public var canBecomeFirstResponder: Bool
    {
        return searchTextField.canBecomeFirstResponder
        
    }
    
    public override var isFirstResponder: Bool
    {
        return searchTextField.isFirstResponder
    }
    
    //MARK: Exposed Functions
    
    public func setShowsCancelButton(_ showsCancelButton: Bool, animated: Bool)
    {
        if showsCancelButton
        {
            if cancelButton == nil
            {
                cancelButton = setupCancelButton()
            }
            if let cancelTrailingConstraint = cancelButtonTrailingConstraint
            {
                cancelTrailingConstraint.priority = UILayoutPriority.init(rawValue: 751)
            }
            cancelButtonIsVisible = true
        } else
        {
            if let cancelTrailingConstraint = cancelButtonTrailingConstraint
            {
                cancelTrailingConstraint.priority = .defaultLow
            }
            cancelButtonIsVisible = false
        }
        if animated
        {
            UIView.animate(withDuration: animationSpeed ?? Constants.defaultAnimationSpeed)
            {
                self.layoutIfNeeded()
            }
        } else
        {
            layoutIfNeeded()
        }
    }
    
    public func pressReturn()
    {
        let _ = searchTextField.delegate?.textFieldShouldReturn?(searchTextField)
    }    
    override public func becomeFirstResponder() -> Bool
    {
        print("becomeFirstResponder called")
        return searchTextField.becomeFirstResponder()
    }
    
    override public func resignFirstResponder() -> Bool
    {
        print("resignFirstResponder called")
        return searchTextField.resignFirstResponder()
    }
    
    //MARK: Class Private Variables
    
    private var searchWindow: SearchBackgroundView
    
    private var searchTextField: UITextField
    
    private var animatedIcon: GlassCursor
    
    private var iconXConstraint: NSLayoutConstraint?
    
    private var cursorRect: CGRect {
        let textPosition = searchTextField.beginningOfDocument
        let cursorRect = searchTextField.caretRect(for: textPosition)
        print("cursorRect = \(cursorRect)")
        return cursorRect
    }
    
    private var textFieldXConstraint: NSLayoutConstraint?
    
    private var searchWindowTrailingConstraint: NSLayoutConstraint?
    
    private var cancelButtonTrailingConstraint: NSLayoutConstraint?
    
    private var savedCursorConstraintConstant: CGFloat
    
    private var iconXConstantNotEditing: CGFloat
    {
        return -animatedIcon.bounds.width/2
    }
    
    private var CursorConstraintOutOfDate = false
    
    private var cancelButtonIsVisible: Bool = false
    
    private struct Constants
    {
        static let defaultBackgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        
        static let defaultAnimationSpeed: Double = 0.25
        
        static let textFieldLeadingConstantEditing: CGFloat = -15.0
        
        static let textFieldLeadingConstantNotEditing: CGFloat = -25.0 //Was -23.0
        
        static let iconXOffsetFromCursorOriginX: CGFloat = 1.0
        
        static let systemFontLargeButton = UIFont.systemFont(ofSize: 17.0)
        
        static let fontMetric = UIFontMetrics(forTextStyle: .body)
        
        private init()
        {
        }
    }
    
    //MARK: Class Initializers
    
    public override init(frame: CGRect)
    {
        searchWindow = SearchBackgroundView(color: Constants.defaultBackgroundColor)
        searchTextField = UITextField()
        let startCursorRect = searchTextField.caretRect(for: searchTextField.beginningOfDocument)
        animatedIcon = GlassCursor(color: .black, cursorRect: startCursorRect)
        savedCursorConstraintConstant = Constants.iconXOffsetFromCursorOriginX
        super.init(frame: frame)
        setupSearchBarLayout()
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        searchWindow = SearchBackgroundView(color: Constants.defaultBackgroundColor)
        searchTextField = UITextField()
        let startCursorRect = searchTextField.caretRect(for: searchTextField.beginningOfDocument)
        animatedIcon = GlassCursor(color: .black, cursorRect: startCursorRect)
        savedCursorConstraintConstant = Constants.iconXOffsetFromCursorOriginX
        super.init(coder: aDecoder)
        setupSearchBarLayout()
    }
    
    //MARK: Setup Subviews
    
    private func setupSearchBarLayout()
    {
        setupSearchWindow(searchWindow)
        
        setupSearchTextField(searchTextField, toView: searchWindow)
        
        setupAnimatedIcon(animatedIcon, toView: searchTextField)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(mainViewTapped(_:)))
        self.addGestureRecognizer(tapRecognizer)
        
        
        self.accessibilityLabel = "UIAnimatedSearchBar"
        
    }
    
    @objc private func mainViewTapped(_ gestureRecognizer: UIGestureRecognizer)
    {
        searchTextField.becomeFirstResponder()
    }
    
    private func setupSearchWindow(_ searchWindow: UIView)
    {
        searchWindow.isOpaque = false
        self.addSubview(searchWindow)
        let leading = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: searchWindow, attribute: .leading, multiplier: 1.0, constant: -8.0)
        leading.identifier = "search window leading to self"
        let trailing = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: searchWindow, attribute: .trailing, multiplier: 1.0, constant: 8.0)
        trailing.identifier = "search window trailing to self"
        trailing.priority = .defaultHigh
        let trailingSuggestion = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .greaterThanOrEqual, toItem: searchWindow, attribute: .trailing, multiplier: 1.0, constant: 8.0)
        trailingSuggestion.priority = UILayoutPriority(rawValue: 999)
        let top = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: searchWindow, attribute: .top, multiplier: 1.0, constant: -10.0)
        top.identifier = "search window top to self"
        let bottom = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: searchWindow, attribute: .bottom, multiplier: 1.0, constant: 10.0)
        bottom.identifier = "search window bottom to self"
        let searchWindowConstraints = [leading, trailing, trailingSuggestion, top, bottom]
        NSLayoutConstraint.activate(searchWindowConstraints)
        searchWindow.translatesAutoresizingMaskIntoConstraints = false
        searchWindowTrailingConstraint = trailing
    }
    
    private func setupSearchTextField(_ searchTextField: UITextField, toView searchWindow: UIView)
    {
        searchTextField.delegate = self
        searchWindow.addSubview(searchTextField)
        searchTextField.tintColor = tintColor.withAlphaComponent(0.95)
        searchTextField.returnKeyType = .search
        searchTextField.autocorrectionType = .no
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.rightViewMode = .unlessEditing
        searchTextField.accessibilityLabel = "searchTextField"
        searchTextField.font = Constants.fontMetric.scaledFont(for: Constants.systemFontLargeButton)
        searchTextField.adjustsFontForContentSizeCategory = true
        searchTextField.addTarget(self, action: #selector(textFieldWillChange(_:)), for: UIControl.Event.editingChanged)
        
        //let textHeight = NSLayoutConstraint(item: searchTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 21.0)
        let textLeading = NSLayoutConstraint(item: searchWindow, attribute: .leading, relatedBy: .equal, toItem: searchTextField, attribute: .leading, multiplier: 1.0, constant: Constants.textFieldLeadingConstantNotEditing)
        textLeading.identifier = "textField to searchWindow leading"
        let textTrailing = NSLayoutConstraint(item: searchWindow, attribute: .trailing, relatedBy: .equal, toItem: searchTextField, attribute: .trailing, multiplier: 1.0, constant: 8.0)
        textTrailing.identifier = "textField to searchWindow trailing"
        let textTop = NSLayoutConstraint(item: searchWindow, attribute: .top, relatedBy: .equal, toItem: searchTextField, attribute: .top, multiplier: 1.0, constant: -7.0)
        textTop.identifier = "textField to searchWindow top"
        let textBottom = NSLayoutConstraint(item: searchWindow, attribute: .bottom, relatedBy: .equal, toItem: searchTextField, attribute: .bottom, multiplier: 1.0, constant: 8.0)
        textBottom.identifier = "textField to searchWindow bottom"
        let searchTextViewConstraints = [textLeading, textTrailing, textTop, textBottom]
        NSLayoutConstraint.activate(searchTextViewConstraints)
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        textFieldXConstraint = textLeading
    }
    
    private func setupAnimatedIcon(_ animatedIcon: GlassCursor, toView searchTextField: UITextField)
    {
        animatedIcon.cursorRect = cursorRect
        animatedIcon.currentState = .glass
        animatedIcon.attachedTextField = searchTextField
        animatedIcon.color = searchTextField.tintColor.withAlphaComponent(0.95)
        animatedIcon.isUserInteractionEnabled = false

        searchTextField.addSubview(animatedIcon)
        
        let iconHeight = NSLayoutConstraint(item: animatedIcon, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: animatedIcon.bounds.height)
        let iconWidth = NSLayoutConstraint(item: animatedIcon, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: animatedIcon.bounds.width)
        let iconMidx = NSLayoutConstraint(item: animatedIcon, attribute: .centerX, relatedBy: .equal, toItem: searchTextField, attribute: .leading, multiplier: 1.0, constant: iconXConstantNotEditing)
        let iconMidy = NSLayoutConstraint(item: animatedIcon, attribute: .top, relatedBy: .equal, toItem: searchTextField, attribute: .top, multiplier: 1.0, constant: 0.0)
        let iconConstraints = [iconMidx, iconMidy, iconWidth, iconHeight]
        NSLayoutConstraint.activate(iconConstraints)
        animatedIcon.translatesAutoresizingMaskIntoConstraints = false
        iconXConstraint = iconMidx
    }
    
    private func setupCancelButton() -> UIButton
    {
        let cancelButton = UIButton(type: .system)
        let cancelText = NSLocalizedString("Cancel", comment: "")
        cancelButton.setTitle(cancelText, for: .normal)
        cancelButton.isEnabled = searchTextField.isEditing
        cancelButton.titleLabel?.font = Constants.fontMetric.scaledFont(for: Constants.systemFontLargeButton)
        cancelButton.titleLabel?.adjustsFontForContentSizeCategory = true
        cancelButton.tintColor = tintColor.withAlphaComponent(0.95)
        cancelButton.addTarget(self, action: #selector(cancelButtonClicked), for: UIControl.Event.touchUpInside)
        self.addSubview(cancelButton)
        
        cancelButton.setContentCompressionResistancePriority(UILayoutPriority.init(rawValue: 752), for: .horizontal)
        let leading = NSLayoutConstraint(item: searchWindow, attribute: .trailing, relatedBy: .equal, toItem: cancelButton, attribute: .leading, multiplier: 1.0, constant: -10.0)
        let trailing = NSLayoutConstraint(item: cancelButton, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -8.0)
        trailing.priority = .defaultLow
        let baseline = NSLayoutConstraint(item: searchTextField, attribute: .firstBaseline, relatedBy: .equal, toItem: cancelButton, attribute: .firstBaseline, multiplier: 1.0, constant: 0.0)
        let cancelButtonConstraints = [leading, trailing, baseline]
        NSLayoutConstraint.activate(cancelButtonConstraints)
        cancelButton.translatesAutoresizingMaskIntoConstraints  = false
        cancelButtonTrailingConstraint = trailing
        layoutIfNeeded()
        return cancelButton
    }
    
    //MARK: Private Functions
    
    @objc private func textFieldWillChange(_ textField: UITextField)
    {
        delegate?.searchBar?(self, textDidChange: textField.text ?? "")
    }
    
    @objc private func bookmarkButtonClicked()
    {
        delegate?.searchBarBookmarkButtonClicked?(self)
    }
    
    @objc private func cancelButtonClicked()
    {
        CursorConstraintOutOfDate = false
        delegate?.searchBarCancelButtonClicked?(self)
    }
}

extension UIAnimatedSearchBar: UITextFieldDelegate
{
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        return delegate?.searchBar?(self, shouldChangeTextIn: range, replacementText: string) ?? true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        switch animatedIcon.currentState
        {
        case .glass:
            if let delegateShouldBeginEditing = delegate?.searchBarShouldBeginEditing?(self)
            {
                guard delegateShouldBeginEditing  else
                {
                    return false
                }
            }
            animatedIcon.rotateToCursor()
            iconXConstraint?.constant = CGFloat(textField.caretRect(for: textField.endOfDocument).origin.x) + Constants.iconXOffsetFromCursorOriginX
            textFieldXConstraint?.constant = Constants.textFieldLeadingConstantEditing
            UIView.animate(withDuration: animationSpeed ?? Constants.defaultAnimationSpeed)
            {
                self.layoutIfNeeded()
            }
            return false
        case .cursor:
            return true
        default:
            return false
        }
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.searchBarTextDidBeginEditing?(self)
        cancelButton?.isEnabled = true
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool
    {
        if let shouldEndEditing = delegate?.searchBarShouldEndEditing?(self)
        {
            guard shouldEndEditing else
            {
                return false
            }
        }
        moveIconForReveal(for: textField)
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField)
    {
        delegate?.searchBarTextDidEndEditing?(self)
        animatedIcon.rotateToGlass()
        print("iconXConstantNotEditing = \(iconXConstantNotEditing)")
        iconXConstraint?.constant = iconXConstantNotEditing
        textFieldXConstraint?.constant = Constants.textFieldLeadingConstantNotEditing
        cancelButton?.isEnabled = false
        UIView.animate(withDuration: animationSpeed ?? Constants.defaultAnimationSpeed)
        {
            self.layoutIfNeeded()
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.searchBarSearchButtonClicked?(self)
        return true
    }
    
    //MARK: Supporting method to position icon on cursor
    
    private func moveIconForReveal(for textField: UITextField)
    {
        iconXConstraint?.constant = CGFloat(textField.caretRect(for: textField.selectedTextRange!.end).origin.x) + Constants.iconXOffsetFromCursorOriginX
        searchTextField.rightViewMode = .always
        self.layoutIfNeeded()
        searchTextField.rightViewMode = .unlessEditing
    }
}
