//
//  GlassCursor.swift
//  QuickTest
//
//  Created by Kyle Burkholder on 5/28/18.
//  Copyright © 2018 Kyle Burkholder. All rights reserved.
//

import Foundation
import UIKit

class GlassCursor: UIView
{
    struct AnimationConstant
    {
        static let toGlassDuration: Double = 0.5
        
        static let toCursorDuration: Double = 0.5
        
        static let cursorRotatedTransform: CATransform3D =
        {
            let zRotTransform = CATransform3DMakeRotation(-CGFloat.pi / 4.0, 0, 0, 1)
            return CATransform3DRotate(zRotTransform, CGFloat.pi/2.0, 0, 1, 0)
        }()
        
        static let animationDamping: CGFloat = 40.0
        
        static let animationMass: CGFloat = 3.0
        
        static let animationStiffness: CGFloat = 1000.0
        
        private init()
        {
        }
    }
    
    enum State
    {
        case glass
        case cursor
        case transition
    }
    
    private let spyGlassLayer = CAShapeLayer()
    
    private let cursorLayer = CATransformLayer()
    
    var attachedTextField: UITextField?
    
    var color: UIColor
    {
        didSet
        {
            if let cursorLayers = cursorLayer.sublayers, let spyGlassLayers = spyGlassLayer.sublayers
            {
                let allLayers = cursorLayers + spyGlassLayers
                for layer in allLayers
                {
                    if let caShapeLayer = layer as? CAShapeLayer
                    {
                        caShapeLayer.fillColor = color.cgColor
                    }
                }
            }
        }
            
    }
    
    var animationSpeed: Double?
    
    var currentState: State = .cursor
    
    var cursorRect: CGRect
    
    init(color: UIColor, cursorRect rect: CGRect)
    {
        //let newFrame = CGRect(x: -15.5 + point.x, y: -6.5 + point.y, width: 34, height: 33)
        let newFrame = CGRect(x: 0, y: 0, width: rect.size.height, height: rect.size.height)
        print(newFrame)
        
        self.color = color
        self.cursorRect = rect
        super.init(frame: newFrame)
        self.addGlassLayer()
        self.addCursorLayer()
    }
    
    override private init(frame: CGRect)
    {
        fatalError("init(frame:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        switch currentState
        {
        case .cursor:
            setCursor()
        case .glass:
            setGlass()
        default:
            return
        }
    }

    private func addGlassLayer()
    {
        spyGlassLayer.frame = self.frame
        let glassLayer = CAShapeLayer()
        let glassPath = UIBezierPath()
        let stemLayer = CAShapeLayer()
        let stemPath = UIBezierPath(roundedRect: CGRect(x: bounds.width/2.0 - cursorRect.size.width/2.0, y: 0, width: cursorRect.size.width, height: cursorRect.size.height), cornerRadius: 1)
        let mainGlass = UIBezierPath(ovalIn: CGRect(x: bounds.width/2.0 - (cursorRect.size.height * 3/5)/2, y: 0, width: cursorRect.size.height * 3/5, height: cursorRect.size.height * 3/5))
        let mainHole = UIBezierPath(ovalIn: CGRect(x: bounds.width/2.0 - (cursorRect.size.height * 9/20)/2, y: cursorRect.size.height * 1.5/20, width: cursorRect.size.height * 9/20, height: cursorRect.size.height * 9/20))
        
        let stemMask = UIBezierPath()
        stemMask.move(to: CGPoint(x: bounds.width/2.0 - (cursorRect.size.height * 3/5)/2, y: cursorRect.size.height * 3/5))
        stemMask.addArc(withCenter: CGPoint(x: bounds.width/2.0, y: (cursorRect.size.height * 3/5)/2), radius: (cursorRect.size.height * 9/20)/2, startAngle: CGFloat.pi, endAngle: 2.0 * CGFloat.pi, clockwise: false)
        stemMask.addLine(to: CGPoint(x: bounds.width/2.0 + (cursorRect.size.height * 9/20)/2, y: bounds.height))
        stemMask.addLine(to: CGPoint(x: bounds.width/2.0 - (cursorRect.size.height * 9/20)/2, y: bounds.height))
        stemMask.close()
        let stemLayerMask = CAShapeLayer()
        stemLayerMask.path = stemMask.cgPath
        stemLayer.path = stemPath.cgPath
        stemLayer.mask = stemLayerMask
        glassPath.append(mainGlass)
        glassPath.append(mainHole)
        glassLayer.path = glassPath.cgPath
        glassLayer.fillColor = color.cgColor
        stemLayer.fillColor = color.cgColor
        glassLayer.fillRule = CAShapeLayerFillRule.evenOdd
        spyGlassLayer.addSublayer(glassLayer)
        spyGlassLayer.addSublayer(stemLayer)
        self.layer.addSublayer(spyGlassLayer)
        spyGlassLayer.transform = CATransform3DMakeRotation(CGFloat.pi/2.0, 0, 1, 0)
    }
    
    private func addCursorLayer()
    {
        cursorLayer.frame = self.frame
        let glassShapePath = UIBezierPath()
        let glassMainLayer = CAShapeLayer()
        let bottomStem = UIBezierPath()
        let startXLocation = bounds.width/2.0 - cursorRect.size.width/2.0
        
        bottomStem.move(to: CGPoint(x: startXLocation, y: cursorRect.size.height * 3/5 - (cursorRect.size.height * 3/5 - cursorRect.size.height * 9/20)/2))
        bottomStem.addLine(to: CGPoint(x: startXLocation, y: cursorRect.size.height - 1))
        bottomStem.addArc(withCenter: CGPoint(x: bounds.width/2.0, y: cursorRect.size.height - 1), radius: 1, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 2.0, clockwise: false)
        bottomStem.addLine(to: CGPoint(x: bounds.width/2.0 + cursorRect.size.width/2.0, y: cursorRect.size.height * 3/5 - (cursorRect.size.height * 3/5 - cursorRect.size.height * 9/20)/4))
        
        bottomStem.close()
        let topStem = UIBezierPath(roundedRect: CGRect(x: startXLocation, y: 0, width: cursorRect.width, height: 1.5), cornerRadius: 1)
        
        let firstSegment = UIBezierPath(rect: CGRect(x: startXLocation, y: (cursorRect.size.height * 3/5)/12, width: cursorRect.width, height: cursorRect.size.height/18.6666))
        let secondSegment = UIBezierPath(rect: CGRect(x: startXLocation, y: 2 * (cursorRect.size.height * 3/5)/12, width: cursorRect.width, height: cursorRect.size.height/18.6666))
        let thirdSegment = UIBezierPath(rect: CGRect(x: startXLocation, y: 3 * (cursorRect.size.height * 3/5)/12, width: cursorRect.width, height: cursorRect.size.height/18.6666))
        let forthSegment = UIBezierPath(rect: CGRect(x: startXLocation, y: 4 * (cursorRect.size.height * 3/5)/12, width: cursorRect.width, height: cursorRect.size.height * 4/18.6666))
        let fifthSegment = UIBezierPath(rect: CGRect(x: startXLocation, y: 8 * (cursorRect.size.height * 3/5)/12, width: cursorRect.width, height: cursorRect.size.height/18.6666))
        let sixSegment = UIBezierPath(rect: CGRect(x: startXLocation, y: 9 * (cursorRect.size.height * 3/5)/12, width: cursorRect.width, height: cursorRect.size.height/18.6666))
        let seventhSegment = UIBezierPath(rect: CGRect(x: startXLocation, y: 10 * (cursorRect.size.height * 3/5)/12, width: cursorRect.width, height: cursorRect.size.height/18.6666))
        for slices in 1...4
        {
            let currentLayer = CAShapeLayer()
            let positiveCurrentLayer = CAShapeLayer()
            let currentPath = UIBezierPath()
            switch slices
            {
            case 1:
                currentLayer.transform = CATransform3DMakeTranslation(0, 0, -(cursorRect.size.height * 3/5 + cursorRect.size.height * 9/20)/4)
                positiveCurrentLayer.transform = CATransform3DMakeTranslation(0, 0, (cursorRect.size.height * 3/5 + cursorRect.size.height * 9/20)/4)
                currentPath.append(forthSegment)
            case 2:
                currentLayer.transform = CATransform3DMakeTranslation(0, 0, -(cursorRect.size.height * 3/5 + cursorRect.size.height * 9/20)*4/5/4)
                positiveCurrentLayer.transform = CATransform3DMakeTranslation(0, 0, (cursorRect.size.height * 3/5 + cursorRect.size.height * 9/20)*4/5/4)
                currentPath.append(thirdSegment)
                currentPath.append(fifthSegment)
            case 3:
                currentLayer.transform = CATransform3DMakeTranslation(0, 0, -(cursorRect.size.height * 3/5 + cursorRect.size.height * 9/20)*3/5/4)
                positiveCurrentLayer.transform = CATransform3DMakeTranslation(0, 0, (cursorRect.size.height * 3/5 + cursorRect.size.height * 9/20)*3/5/4)
                currentPath.append(secondSegment)
                currentPath.append(sixSegment)
            case 4:
                currentLayer.transform = CATransform3DMakeTranslation(0, 0, -(cursorRect.size.height * 3/5 + cursorRect.size.height * 9/20)*2/5/4)
                positiveCurrentLayer.transform = CATransform3DMakeTranslation(0, 0, (cursorRect.size.height * 3/5 + cursorRect.size.height * 9/20)*2/5/4)
                currentPath.append(firstSegment)
                currentPath.append(seventhSegment)
            default:
                continue
            }
            currentLayer.path = currentPath.cgPath
            currentLayer.fillColor = color.cgColor
            positiveCurrentLayer.path = currentPath.cgPath
            positiveCurrentLayer.fillColor = color.cgColor
            cursorLayer.addSublayer(currentLayer)
            cursorLayer.addSublayer(positiveCurrentLayer)
        }
        
        glassShapePath.append(bottomStem)
        glassShapePath.append(topStem)
        glassMainLayer.path = glassShapePath.cgPath
        glassMainLayer.fillColor = color.cgColor
        cursorLayer.addSublayer(glassMainLayer)
        self.layer.addSublayer(cursorLayer)
    }
    
    func rotateToGlass()
    {
        self.currentState = .transition
        self.isHidden = false
        let rotationAnimationZ = CASpringAnimation(keyPath: "transform")
        rotationAnimationZ.fromValue = CATransform3DMakeRotation(CGFloat.pi/2.0, 0, 1, 0)
        rotationAnimationZ.toValue = CATransform3DMakeRotation(-CGFloat.pi/4, 0, 0, 1)
        rotationAnimationZ.duration = animationSpeed ?? AnimationConstant.toGlassDuration
        rotationAnimationZ.isRemovedOnCompletion = false
        rotationAnimationZ.fillMode = CAMediaTimingFillMode.forwards
        rotationAnimationZ.damping = AnimationConstant.animationDamping
        rotationAnimationZ.mass = AnimationConstant.animationMass
        rotationAnimationZ.stiffness = AnimationConstant.animationStiffness
        spyGlassLayer.add(rotationAnimationZ, forKey: nil)
        
        let cursorRotationAnimationZ = CASpringAnimation(keyPath: "transform")
        cursorRotationAnimationZ.toValue = AnimationConstant.cursorRotatedTransform
        cursorRotationAnimationZ.duration = animationSpeed ?? AnimationConstant.toGlassDuration
        cursorRotationAnimationZ.isRemovedOnCompletion = false
        cursorRotationAnimationZ.fillMode = CAMediaTimingFillMode.forwards
        cursorRotationAnimationZ.damping = AnimationConstant.animationDamping
        cursorRotationAnimationZ.mass = AnimationConstant.animationMass
        cursorRotationAnimationZ.stiffness = AnimationConstant.animationStiffness
        cursorLayer.add(cursorRotationAnimationZ, forKey: nil)
        
        Timer.scheduledTimer(withTimeInterval: animationSpeed ?? AnimationConstant.toGlassDuration, repeats: false)
        {
            _ in
            self.setGlass()
        }
    }
    
    func rotateToCursor()
    {
        self.currentState = .transition
        cursorLayer.isHidden = false
        let rotationAnimationZ = CASpringAnimation(keyPath: "transform")
        rotationAnimationZ.fromValue = CATransform3DMakeRotation(-CGFloat.pi/4, 0, 0, 1)
        rotationAnimationZ.toValue = CATransform3DMakeRotation(CGFloat.pi/2.0, 0, 1, 0)
        rotationAnimationZ.duration = animationSpeed ?? AnimationConstant.toCursorDuration
        rotationAnimationZ.isRemovedOnCompletion = false
        rotationAnimationZ.fillMode = CAMediaTimingFillMode.forwards
        rotationAnimationZ.damping = AnimationConstant.animationDamping
        rotationAnimationZ.mass = AnimationConstant.animationMass
        rotationAnimationZ.stiffness = AnimationConstant.animationStiffness
        spyGlassLayer.add(rotationAnimationZ, forKey: nil)
    
        let cursorRotationAnimationZ = CASpringAnimation(keyPath: "transform")
        cursorRotationAnimationZ.fromValue = AnimationConstant.cursorRotatedTransform
        cursorRotationAnimationZ.toValue = CATransform3DIdentity
        cursorRotationAnimationZ.duration = animationSpeed ?? AnimationConstant.toCursorDuration
        cursorRotationAnimationZ.isRemovedOnCompletion = false
        cursorRotationAnimationZ.fillMode = CAMediaTimingFillMode.forwards
        cursorRotationAnimationZ.damping = AnimationConstant.animationDamping
        cursorRotationAnimationZ.mass = AnimationConstant.animationMass
        cursorRotationAnimationZ.stiffness = AnimationConstant.animationStiffness
        cursorLayer.add(cursorRotationAnimationZ, forKey: nil)
        
        Timer.scheduledTimer(withTimeInterval: animationSpeed ?? AnimationConstant.toCursorDuration, repeats: false)
        {
            _ in
            self.setCursor()
        }
    }
    
    private func setGlass()
    {
        self.currentState = .glass
        self.spyGlassLayer.transform = CATransform3DMakeRotation(-CGFloat.pi/4, 0, 0, 1)
        cursorLayer.isHidden = true
    }
    
    private func setCursor()
    {
        self.currentState = .cursor
        self.isHidden = true
        self.cursorLayer.transform = CATransform3DIdentity
        attachedTextField?.becomeFirstResponder()
    }
}
