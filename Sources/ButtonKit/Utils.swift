//
//  Utils.swift
//  
//
//  Created by Tobbe on 2020-05-25.
//

import Foundation
import UIKit


public class Utils {

    class public func modulus(_ originalNumber: Int, modulusNumber: Int) -> Int {
    
        return (originalNumber % modulusNumber + modulusNumber) % modulusNumber
    
    }
    
    class public func randomFloat(between: CGFloat, and: CGFloat) -> CGFloat {
    
        let number = CGFloat(arc4random_uniform(UInt32((and * 100.0 - between * 100.0)))) + CGFloat(between * 100.0)
        
        return number / 100.0
    
    }
    
    class public func randomInt(between: Int, and: Int) -> Int {
    
        let number = Int(arc4random_uniform(UInt32((and - between)))) + Int(between)
        
        return number
    
    }

}


// MARK: - Maths


public class Maths {

    

}


// MARK: - Dispatch


public class Dispatch {

    static let backgroundQueue: DispatchQueue = DispatchQueue(label: "BackgroundQueue")
    
    
    class public func main(_ block: (() -> Void)?) {
    
        guard let block = block else { return }
        
        DispatchQueue.main.async(execute: block)
    
    }
    
    class public func main(after seconds: CGFloat, _ block: (() -> Void)?) {
    
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(seconds * 1000))) {
        
            block?()
        
        }
    
    }
    
    class public func background(_ block: (() -> Void)?) {
    
        guard let block = block else { return }
        
        self.backgroundQueue.async(execute: block)
    
    }

}


// MARK: - Colors


public class Color {

    

}


extension UIColor {

    public func contrast(intensity: CGFloat) -> UIColor {
    
        return brightness > 0.65 ? darkerColor(intensity: intensity) : lighterColor(intensity: intensity)
    
    }
    
    public var brightness: CGFloat {
    
        var brightness: CGFloat = 0
        let colorComponents = self.cgColor.components
        
        if (self.cgColor.numberOfComponents == 4) {
        
            let redComponent = (colorComponents?[0])! * 0.50
            let greenComponent = (colorComponents?[1])! * 2.00
            let blueComponent = (colorComponents?[2])! * 0.50
            
            brightness = (redComponent + greenComponent + blueComponent) / 3.0
        
        } else if (self.cgColor.numberOfComponents == 2) {
        
            let whiteComponent = colorComponents?[0]
            
            brightness = whiteComponent!
        
        }
        
        return brightness
    
    }
    
    public func darkerColor(intensity: CGFloat) -> UIColor {
    
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        let updatedBrightness: CGFloat = 100 * brightness * (1.0 - pow(intensity, 2))
        let updatedSaturation = 100 * saturation + (intensity * 100 * saturation)
        
        //print("saturation: \(100 * saturation) intensity: \(intensity) updatedSaturation: \(updatedSaturation)")
        
        return UIColor(hue: hue, saturation: updatedSaturation / 100, brightness: updatedBrightness / 100, alpha: alpha)
    
    }
    
    public func lighterColor(intensity: CGFloat) -> UIColor {
    
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        var updatedBrightness: CGFloat = 100 * brightness + 100 * (1.0 - brightness) * intensity * 1.2
        var updatedSaturation: CGFloat = 100 * saturation - (100 * saturation * 1.0 * intensity * 1.35 * (1.0 - brightness * 0.20))
        
        updatedBrightness = max(0, min(100.0, updatedBrightness))
        updatedSaturation = max(0, min(100.0, updatedSaturation))
        
        //print("saturation: \(100 * saturation) intensity: \(intensity) updatedSaturation: \(updatedSaturation)")
        //print("brightness: \(100 * brightness) intensity: \(intensity) updatedBrightness: \(updatedBrightness)")
        
        return UIColor(hue: hue, saturation: updatedSaturation / 100, brightness: updatedBrightness / 100, alpha: alpha)
    
    }
    
    public convenience init(hex: String) {
    
        let r, g, b: CGFloat
        
        let start = hex.index(hex.startIndex, offsetBy: 0)
        let hexColor = String(hex[start...])
        
        guard hexColor.count == 6 else { self.init(red: 0, green: 0, blue: 0, alpha: 0); return }
        
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        
        guard scanner.scanHexInt64(&hexNumber) else { self.init(red: 0, green: 0, blue: 0, alpha: 0); return }
        
        r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
        g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
        b = CGFloat((hexNumber & 0x0000ff) >> 0) / 255
        
        self.init(red: r, green: g, blue: b, alpha: 1)
    
    }

}
