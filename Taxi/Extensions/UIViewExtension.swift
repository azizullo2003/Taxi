//
//  UIViewProtocols.swift
//  QuizApp
//
//  Created by eldorbek nusratov on 04/02/2021.
//

import UIKit

struct ShadowStyleStruct {
    var shadowColor: CGColor
    var shadowPath: CGPath
    var shadowOffset: CGSize
    var shadowOpacity: Float
    var shadowRadius: CGFloat
}

enum ShadowStyle {
    case style1
    case style2
    case style3
}

public enum Direction: Int {
    case Up
    case Down
    case Left
    case Right
    
    public var isX: Bool { return self == .Left || self == .Right }
    public var isY: Bool { return !isX }
}


extension UIView {
    
    func aspectRatio(ratio: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: ratio).isActive = true
    }
    
    func clipToCirle(){
        layoutIfNeeded()
        self.clipsToBounds = true
        self.layer.cornerRadius =  self.bounds.width / 2
    }
  
    
    func doCircleView(){
        
        let width = self.frame.width
        self.layer.cornerRadius = width / 2
        
        self.clipsToBounds = true
    }
}

extension UIView {
    
    func setShadow(shadowStyle: ShadowStyleStruct, shadowLayer: CAShapeLayer) -> CAShapeLayer{
        shadowLayer.shadowColor = shadowStyle.shadowColor
        shadowLayer.shadowPath = shadowStyle.shadowPath
        shadowLayer.shadowOffset = shadowStyle.shadowOffset
        shadowLayer.shadowOpacity = shadowStyle.shadowOpacity
        shadowLayer.shadowRadius = shadowStyle.shadowRadius
        return shadowLayer
    }
    
    
    
    func setShadowCornerBorder(shadow style: ShadowStyle, cornerRadius : CGFloat?, borderWidth: CGFloat?, borderColor: CGColor?){
        
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius ?? 0).cgPath
        shadowLayer.borderWidth = borderWidth ?? 0
        shadowLayer.borderColor = borderColor ?? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        switch style {
        case .style1: break
        case .style2: break
        case .style3: break
        }
        
        layer.insertSublayer(shadowLayer, at: 0)
    }
    
    func setShadowWithCorner(cornerRadius: CGFloat, color: UIColor) {
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        shadowLayer.fillColor = color.cgColor
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        shadowLayer.shadowOpacity = 0.8
        shadowLayer.shadowRadius = 3
        self.layer.insertSublayer(shadowLayer, at: 0)
    }
    
    func loadViewFromNib(nibName: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    func renderViewToImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        let image = renderer.image { ctx in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
        return image
    }
}


// MARK : - UIBUtton extension
extension UIButton{
    
    public enum UIButtonBorderSide {
        case Top, Bottom, Left, Right
    }
    
    func changeSizeImage(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat){
        //        self.imageEdgeInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        //        self.contentMode = .scaleToFill
    }
    
    public func addBorder(side: UIButtonBorderSide, color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        switch side {
        case .Top:
            border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: width)
        case .Bottom:
            border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        case .Left:
            border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        case .Right:
            border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        }
        
        self.layer.addSublayer(border)
    }
    
    func setBackgroundColorAndShadow(){
        self.clipsToBounds = false
        let shadowSize: CGFloat = 10
        let contactRect = CGRect(x: shadowSize / 2, y: self.frame.height / 2, width: self.frame.width - shadowSize, height: self.frame.height - shadowSize)
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(roundedRect: frame, cornerRadius: frame.width / 2).cgPath
        shadowLayer.shadowColor = #colorLiteral(red: 0.2431372549, green: 0, blue: 0.3450980392, alpha: 0.25).cgColor
        shadowLayer.fillColor =  #colorLiteral(red: 0.5994561911, green: 0.1946301758, blue: 0.685857594, alpha: 1).cgColor
        shadowLayer.accessibilityLabel = "Back"
//        shadowLayer.backgroundColor = UIColor.clear.cgColor
        shadowLayer.shadowPath = UIBezierPath(ovalIn: contactRect).cgPath
        shadowLayer.shadowOpacity = 1
        self.layer.insertSublayer(shadowLayer, below: self.layer)
    }
    
    func setShadow(){
        self.clipsToBounds = false
        let shadowSize: CGFloat = 10
        let contactRect = CGRect(x: shadowSize / 2, y: self.frame.height / 2, width: self.frame.width - shadowSize, height: self.frame.height - shadowSize)
        let shadowLayer = CAShapeLayer()
        print("Button 1 \(frame)")
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: frame.width / 2).cgPath
        shadowLayer.shadowColor = #colorLiteral(red: 0.2431372549, green: 0, blue: 0.3450980392, alpha: 0.25).cgColor
        shadowLayer.fillColor = .none
        shadowLayer.shadowPath = UIBezierPath(ovalIn: contactRect).cgPath
        shadowLayer.shadowOpacity = 1
        self.layer.insertSublayer(shadowLayer, below: self.layer)
    }
    
}


public extension UIPanGestureRecognizer {
    
    var direction: Direction? {
        let velo = velocity(in: view)
        //        let velocity = velocity(in: view)
        let vertical = abs(velo.y) > abs(velo.x)
        switch (vertical, velo.x, velo.y) {
        case (true, _, let y) where y < 0: return .Up
        case (true, _, let y) where y > 0: return .Down
        case (false, let x, _) where x > 0: return .Right
        case (false, let x, _) where x < 0: return .Left
        default: return nil
        }
    }
}
