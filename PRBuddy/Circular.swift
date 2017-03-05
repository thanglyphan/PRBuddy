//
//  Circular.swift
//  PRBuddy
//
//  Created by Thang on 26.12.2016.
//  Copyright © 2016 Thangphan. All rights reserved.
//

import UIKit

@IBDesignable class DesignableImageView: UIImageView {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
}
@IBDesignable class DesignableButton:UIButton {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

extension UIView {
    @IBInspectable
    var borderWidth :CGFloat {
        get {
            return layer.borderWidth
        }
        
        set(newBorderWidth){
            layer.borderWidth = newBorderWidth
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get{
            return layer.borderColor != nil ? UIColor(cgColor: layer.borderColor!) :nil
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var cornerRadius :CGFloat {
        get {
            return layer.cornerRadius
        }
        
        set{
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue != 0
        }
    }
    
    @IBInspectable
    var makeCircular:Bool? {
        get{
            return nil
        }
        
        set {
            if let makeCircular = newValue, makeCircular {
                cornerRadius = min(bounds.width, bounds.height) / 2.0
            }
        }
    }
}
