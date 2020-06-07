//
//  Spinner.swift
//  
//
//  Created by Tobbe on 2020-05-25.
//

import Foundation
import UIKit


public class Spinner: UIView {

    public var isAnimating: Bool = false
    public var dotDiameter: CGFloat = 7.0
    
    public var color: UIColor = UIColor.clear { didSet { updateColors() } }
    
    private var one: Circle!
    private var two: Circle!
    private var three: Circle!
    
    
    convenience init(color: UIColor) {
    
        self.init()
        self.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        self.clipsToBounds = false
        self.color = color
        self.initDots()
    
    }
    
    private func initDots() {
    
        let centerOne = CGPoint(x: -dotDiameter/2, y: self.bounds.midY)
        let centerTwo = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let centerThree = CGPoint(x: self.bounds.maxX + dotDiameter/2, y: self.bounds.midY)
        
        self.one = Circle(diameter: dotDiameter, center: centerOne, fill: color)
        self.one.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        
        self.two = Circle(diameter: dotDiameter, center: centerTwo, fill: color)
        self.two.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        
        self.three = Circle(diameter: dotDiameter, center: centerThree, fill: color)
        self.three.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin]
        
        self.addSubview(one)
        self.addSubview(two)
        self.addSubview(three)
        
        self.isHidden = true
    
    }
    
    private func updateColors() {
    
        self.one.fillColor = color
        self.two.fillColor = color
        self.three.fillColor = color
    
    }
    
    public func startAnimating() {
    
        guard !self.isAnimating else { return }
        
        self.isHidden = false
        self.isAnimating = true
        
        let duration: Double = 0.600
        let interval: CGFloat = 0.200
        let scale: CGFloat = 0.500
        
        for (dotNumber, dot) in [one, two, three].enumerated() {
        
            dot?.transform = transform.scaledBy(x: scale, y: scale)
            
            Dispatch.main(after: CGFloat(dotNumber) * interval) {
            
                UIView.animate(withDuration: duration, delay: 0, options: ([UIView.AnimationOptions.autoreverse, UIView.AnimationOptions.repeat]), animations: { () -> Void in
                
                    dot?.transform = CGAffineTransform.identity
                
                }, completion: nil)
            
            }
        
        }
    
    }
    
    public func stopAnimating() {
    
        self.isHidden = true
        self.isAnimating = false
        
        for dot in [one, two, three] {
        
            dot?.layer.removeAllAnimations()
            dot?.transform = CGAffineTransform.identity
        
        }
    
    }

}


class Circle: UIView {

    public var fillColor: UIColor? { didSet { self.setNeedsDisplay() } }
    
    
    convenience init(diameter: CGFloat, center: CGPoint, fill: UIColor) {
    
        self.init()
        self.frame = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        self.backgroundColor = UIColor.clear
        self.center = center
        
        self.fillColor = fill
    
    }
    
    override func draw(_ rect: CGRect) {
    
        guard let fillColor = self.fillColor else { return }
        
        fillColor.setFill()
        UIBezierPath(ovalIn: rect).fill()
    
    }

}
