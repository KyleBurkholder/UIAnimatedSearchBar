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
    struct AnimationConstanst
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
    
    init(color: UIColor)
    {
        //let newFrame = CGRect(x: -15.5 + point.x, y: -6.5 + point.y, width: 34, height: 33)
        let newFrame = CGRect(x: 0, y: 0, width: 34, height: 34)
        self.color = color
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
        let stemPath = UIBezierPath(roundedRect: CGRect(x: 16, y: 6, width: 2, height: 21), cornerRadius: 1)
        let mainGlass = UIBezierPath(ovalIn: CGRect(x: 11, y: 6, width: 12, height: 12))
        let mainHole = UIBezierPath(ovalIn: CGRect(x: 12.5, y: 7.5, width: 9, height: 9))
        let stemMask = UIBezierPath()
        stemMask.move(to: CGPoint(x: 11, y: 12))
        stemMask.addArc(withCenter: CGPoint(x: 17, y: 12), radius: 6, startAngle: CGFloat.pi, endAngle: 2.0 * CGFloat.pi, clockwise: false)
        stemMask.addLine(to: CGPoint(x: 23, y: 27))
        stemMask.addLine(to: CGPoint(x: 11, y: 27))
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
        glassLayer.fillRule = kCAFillRuleEvenOdd
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
        bottomStem.move(to: CGPoint(x: 16, y: 16.5))
        bottomStem.addLine(to: CGPoint(x: 16, y: 26))
        bottomStem.addArc(withCenter: CGPoint(x: 17, y: 26), radius: 1, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 2.0, clockwise: false)
        bottomStem.addLine(to: CGPoint(x: 18, y: 16.5))
        bottomStem.close()
        
        let topStem = UIBezierPath(roundedRect: CGRect(x: 16, y: 6, width: 2, height: 1.5), cornerRadius: 1)
        
        let firstSegment = UIBezierPath(rect: CGRect(x: 16, y: 7, width: 2, height: 1))
        let secondSegment = UIBezierPath(rect: CGRect(x: 16, y: 8, width: 2, height: 1))
        let thirdSegment = UIBezierPath(rect: CGRect(x: 16, y: 9, width: 2, height: 1))
        let forthSegment = UIBezierPath(rect: CGRect(x: 16, y: 10, width: 2, height: 4))
        let fifthSegment = UIBezierPath(rect: CGRect(x: 16, y: 14, width: 2, height: 1))
        let sixSegment = UIBezierPath(rect: CGRect(x: 16, y: 15, width: 2, height: 1))
        let seventhSegment = UIBezierPath(rect: CGRect(x: 16, y: 16, width: 2, height: 1))
        for slices in 1...4
        {
            let currentLayer = CAShapeLayer()
            let positiveCurrentLayer = CAShapeLayer()
            let currentPath = UIBezierPath()
            switch slices
            {
            case 1:
                currentLayer.transform = CATransform3DMakeTranslation(0, 0, -5)
                positiveCurrentLayer.transform = CATransform3DMakeTranslation(0, 0, 5)
                currentPath.append(forthSegment)
            case 2:
                currentLayer.transform = CATransform3DMakeTranslation(0, 0, -4.5)
                positiveCurrentLayer.transform = CATransform3DMakeTranslation(0, 0, 4.5)
                currentPath.append(thirdSegment)
                currentPath.append(fifthSegment)
            case 3:
                currentLayer.transform = CATransform3DMakeTranslation(0, 0, -4)
                positiveCurrentLayer.transform = CATransform3DMakeTranslation(0, 0, 4)
                currentPath.append(secondSegment)
                currentPath.append(sixSegment)
            case 4:
                currentLayer.transform = CATransform3DMakeTranslation(0, 0, -3)
                positiveCurrentLayer.transform = CATransform3DMakeTranslation(0, 0, 3)
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
        rotationAnimationZ.duration = animationSpeed ?? AnimationConstanst.toGlassDuration
        rotationAnimationZ.isRemovedOnCompletion = false
        rotationAnimationZ.fillMode = kCAFillModeForwards
        rotationAnimationZ.damping = AnimationConstanst.animationDamping
        rotationAnimationZ.mass = AnimationConstanst.animationMass
        rotationAnimationZ.stiffness = AnimationConstanst.animationStiffness
        spyGlassLayer.add(rotationAnimationZ, forKey: nil)
        
        let cursorRotationAnimationZ = CASpringAnimation(keyPath: "transform")
        cursorRotationAnimationZ.toValue = AnimationConstanst.cursorRotatedTransform
        cursorRotationAnimationZ.duration = animationSpeed ?? AnimationConstanst.toGlassDuration
        cursorRotationAnimationZ.isRemovedOnCompletion = false
        cursorRotationAnimationZ.fillMode = kCAFillModeForwards
        cursorRotationAnimationZ.damping = AnimationConstanst.animationDamping
        cursorRotationAnimationZ.mass = AnimationConstanst.animationMass
        cursorRotationAnimationZ.stiffness = AnimationConstanst.animationStiffness
        cursorLayer.add(cursorRotationAnimationZ, forKey: nil)
        
        Timer.scheduledTimer(withTimeInterval: animationSpeed ?? AnimationConstanst.toGlassDuration, repeats: false)
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
        rotationAnimationZ.duration = animationSpeed ?? AnimationConstanst.toCursorDuration
        rotationAnimationZ.isRemovedOnCompletion = false
        rotationAnimationZ.fillMode = kCAFillModeForwards
        rotationAnimationZ.damping = AnimationConstanst.animationDamping
        rotationAnimationZ.mass = AnimationConstanst.animationMass
        rotationAnimationZ.stiffness = AnimationConstanst.animationStiffness
        spyGlassLayer.add(rotationAnimationZ, forKey: nil)
    
        let cursorRotationAnimationZ = CASpringAnimation(keyPath: "transform")
        cursorRotationAnimationZ.fromValue = AnimationConstanst.cursorRotatedTransform
        cursorRotationAnimationZ.toValue = CATransform3DIdentity
        cursorRotationAnimationZ.duration = animationSpeed ?? AnimationConstanst.toCursorDuration
        cursorRotationAnimationZ.isRemovedOnCompletion = false
        cursorRotationAnimationZ.fillMode = kCAFillModeForwards
        cursorRotationAnimationZ.damping = AnimationConstanst.animationDamping
        cursorRotationAnimationZ.mass = AnimationConstanst.animationMass
        cursorRotationAnimationZ.stiffness = AnimationConstanst.animationStiffness
        cursorLayer.add(cursorRotationAnimationZ, forKey: nil)
        
        Timer.scheduledTimer(withTimeInterval: animationSpeed ?? AnimationConstanst.toCursorDuration, repeats: false)
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
