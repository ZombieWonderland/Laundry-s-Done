//
//  LaundryView.swift
//  Half and Half UIStack
//
//  Created by Dan Livingston  on 4/8/16.
//  Copyright © 2016 Zombie Koala. All rights reserved.
//

import UIKit

class LaundryView: UIView {
    
    let washerColor1 = UIColor(red: 0.0/255.0, green: 174.0/255.0, blue: 255.0/255.0, alpha: 1.0).CGColor
    let washerColor2 = UIColor(red: 0.0/255.0, green: 118.0/255.0, blue: 255.0/255.0, alpha: 1.0).CGColor
    
    let dryerColor1 = UIColor(red: 255.0/255.0, green: 150.0/255.0, blue: 0.0/255.0, alpha: 1.0).CGColor
    let dryerColor2 = UIColor(red: 254.0/255.0, green: 56.0/255.0, blue: 36.0/255.0, alpha: 1.0).CGColor
    

    //
    //  Make sure gradient is re-drawn when screen rotates
    //
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let id = self.restorationIdentifier {
            if id == "washer" {
                createGradient(self, color1: washerColor1, color2: washerColor2)
            } else {
                createGradient(self, color1: dryerColor1, color2: dryerColor2)
            }
        }

    }
    
    func createGradient(viewToGradiate: UIView, color1: CGColor, color2: CGColor) {
        //
        //  Clean up gradient sublayers before adding a new one
        //
        if let sublayers = viewToGradiate.layer.sublayers {
            for layer in sublayers {
                if layer is CAGradientLayer {
                    layer.removeFromSuperlayer()
                }
                
            }
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = viewToGradiate.bounds
        gradientLayer.colors = [color1, color2]
        viewToGradiate.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    

}
