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


//@IBDesignable
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
                let button = UIButton(type: UIButtonType.system)
                button.frame = CGRect(x: 0, y: 0, width: 21, height: 21)
                let image = UIImage(named: "bookmarkIcon")?.withRenderingMode(.alwaysTemplate)
                button.setImage(image, for: .normal)
                button.addTarget(self, action: #selector(bookmarkButtonClicked), for: UIControlEvents.touchUpInside)
                searchTextField.rightView = button
            } else
            {
                searchTextField.rightView = nil
            }
        }
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
    
    public var animationSpeed: Double?
    {
        didSet
        {
            animatedIcon.animationSpeed = animationSpeed! / 2.0
        }
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
    
    //MARK: Class Private Variables
    
    private var searchWindow: SearchBackgroundView
    
    private var searchTextField: UITextField
    
    private var animatedIcon: GlassCursor
    
    private var cancelButton: UIButton?
    
    private var iconXConstraint: NSLayoutConstraint?
    
    private var textFieldXConstraint: NSLayoutConstraint?
    
    private var searchWindowTrailingConstraint: NSLayoutConstraint?
    
    private var cancelButtonTrailingConstraint: NSLayoutConstraint?
    
    private var savedCursorConstraintConstant: CGFloat
    
    private var cancelButtonIsVisible: Bool = false
    
    private struct Constants
    {
        static let defaultBackgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        
        static let defaultAnimationSpeed: Double = 0.25
        
        static let textFieldLeadingConstantEditing: CGFloat = -15.0
        
        static let textFieldLeadingConstantNotEditing: CGFloat = -23.0
        
        static let iconXConstantNotEditing: CGFloat = -7.0
        
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
        animatedIcon = GlassCursor(color: .black)
        savedCursorConstraintConstant = 0.0
        super.init(frame: frame)
        setupSearchBarLayout()
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        searchWindow = SearchBackgroundView(color: Constants.defaultBackgroundColor)
        searchTextField = UITextField()
        animatedIcon = GlassCursor(color: .black)
        savedCursorConstraintConstant = 0.0
        super.init(coder: aDecoder)
        setupSearchBarLayout()
    }
    
    //MARK: Setup Subviews
    
    private func setupSearchBarLayout()
    {
        setupSearchWindow(searchWindow)
        
        setupSearchTextField(searchTextField, toView: searchWindow)
        
        setupAnimatedIcon(animatedIcon, toView: searchTextField)
        
    }
    
    private func setupSearchWindow(_ searchWindow: UIView)
    {
        searchWindow.isOpaque = false
        self.addSubview(searchWindow)
        
        let leading = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: searchWindow, attribute: .leading, multiplier: 1.0, constant: -8.0)
        let trailing = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: searchWindow, attribute: .trailing, multiplier: 1.0, constant: 8.0)
        trailing.priority = .defaultHigh
        let trailingSuggestion = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .greaterThanOrEqual, toItem: searchWindow, attribute: .trailing, multiplier: 1.0, constant: 8.0)
        let top = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: searchWindow, attribute: .top, multiplier: 1.0, constant: -10.0)
        let bottom = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: searchWindow, attribute: .bottom, multiplier: 1.0, constant: 10.0)
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
        searchTextField.font = Constants.fontMetric.scaledFont(for: Constants.systemFontLargeButton)
        searchTextField.adjustsFontForContentSizeCategory = true
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
        //let textHeight = NSLayoutConstraint(item: searchTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 21.0)
        let textLeading = NSLayoutConstraint(item: searchWindow, attribute: .leading, relatedBy: .equal, toItem: searchTextField, attribute: .leading, multiplier: 1.0, constant: Constants.textFieldLeadingConstantNotEditing)
        let textTrailing = NSLayoutConstraint(item: searchWindow, attribute: .trailing, relatedBy: .equal, toItem: searchTextField, attribute: .trailing, multiplier: 1.0, constant: 8.0)
        let textTop = NSLayoutConstraint(item: searchWindow, attribute: .top, relatedBy: .equal, toItem: searchTextField, attribute: .top, multiplier: 1.0, constant: -7.0)
        let textBottom = NSLayoutConstraint(item: searchWindow, attribute: .bottom, relatedBy: .equal, toItem: searchTextField, attribute: .bottom, multiplier: 1.0, constant: 8.0)
        let searchTextViewConstraints = [textLeading, textTrailing, textTop, textBottom]
        NSLayoutConstraint.activate(searchTextViewConstraints)
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        textFieldXConstraint = textLeading
    }
    
    private func setupAnimatedIcon(_ animatedIcon: GlassCursor, toView searchTextField: UITextField)
    {
        
        animatedIcon.currentState = .glass
        animatedIcon.attachedTextField = searchTextField
        print(tintColor)
        animatedIcon.color = searchTextField.tintColor.withAlphaComponent(0.95)
        animatedIcon.isUserInteractionEnabled = false

        searchTextField.addSubview(animatedIcon)
        
        let iconHeight = NSLayoutConstraint(item: animatedIcon, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 33)
        let iconWidth = NSLayoutConstraint(item: animatedIcon, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 34)
        let iconMidx = NSLayoutConstraint(item: animatedIcon, attribute: .centerX, relatedBy: .equal, toItem: searchTextField, attribute: .leading, multiplier: 1.0, constant: Constants.iconXConstantNotEditing)
        let iconMidy = NSLayoutConstraint(item: animatedIcon, attribute: .centerY, relatedBy: .equal, toItem: searchTextField, attribute: .firstBaseline, multiplier: 1.0, constant: -6.0)
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
        cancelButton.addTarget(self, action: #selector(cancelButtonClicked), for: UIControlEvents.touchUpInside)
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
    
    @objc private func textFieldDidChange(_ textField: UITextField)
    {
        delegate?.searchBar?(self, textDidChange: textField.text ?? "")
    }
    
    @objc private func bookmarkButtonClicked()
    {
        delegate?.searchBarBookmarkButtonClicked?(self)
    }
    
    @objc private func cancelButtonClicked()
    {
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
            iconXConstraint?.constant = savedCursorConstraintConstant
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
        moveIconForReveal()
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField)
    {
        
        delegate?.searchBarTextDidEndEditing?(self)
        animatedIcon.rotateToGlass()
        iconXConstraint?.constant = Constants.iconXConstantNotEditing
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
    
    //MARK: Supporting methods to position icon on cursor
    
    private func moveIconForReveal()
    {
        savedCursorConstraintConstant = outputTextFieldCursorX(searchTextField) + Constants.iconXOffsetFromCursorOriginX
        iconXConstraint?.constant = savedCursorConstraintConstant
        searchTextField.rightViewMode = .always
        self.layoutIfNeeded()
        searchTextField.rightViewMode = .unlessEditing
    }
    
    private func outputTextFieldCursorX(_ textField: UITextField) -> CGFloat
    {
        let cursorView = findViewLayerFour(textField)
        if let view = cursorView
        {
        return view.convert(view.bounds.origin, to: searchTextField).x
        }
        return 0.0
    }
    
    private func findViewLayerFour(_ view: UIView, depth: Int = 0) -> UIView?
    {
        print(depth)
        print(view.frame)
        if !view.subviews.isEmpty
        {
            for view in view.subviews
            {
                if findViewLayerFour(view, depth: depth + 1) == nil
                {
                    continue
                }
                return findViewLayerFour(view, depth: depth + 1)
            }
        }
        if depth == 4
        {
            return view
        } else
        {
            return nil
        }
    }
}
