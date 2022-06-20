//
//  TargetView.swift
//  elyahk.UztaxiApp
//
//  Created by eldorbek nusratov on 22/02/2021.
//

import UIKit


class Target: UIView {
    
    let jumpHeight : CGFloat = 35
    var height : CGFloat = 0.0
    let duration : TimeInterval = 1
    var inner_square : UIView = {
        var view = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 8))
        view.backgroundColor = #colorLiteral(red: 0.2235294118, green: 0.01176470588, blue: 0.3058823529, alpha: 1)
        return view
    }()
    
    var circle_view : UIImageView = {
        var view = UIImageView()
        var image = UIImage(named: "uztaxi_target_circle")
        view.image = image
        return view
    }()
    var column_view : UIView = {
        var view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.2235294118, green: 0.01176470588, blue: 0.3058823529, alpha: 1)
        return view
    }()
    lazy var targetView: UIView = {
        var view = UIView()
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initSubviews(){
        targetView = UIView(frame: self.bounds)
        self.addSubview(targetView)
        
        height = self.frame.height
        circle_view.frame = CGRect(x: 1.25, y: 0, width: targetView.frame.width, height: targetView.frame.width)
        targetView.addSubview(circle_view)
        
        targetView.addSubview(inner_square)
        inner_square.center = circle_view.center
        
        column_view.frame = CGRect(x: targetView.frame.width / 2.02, y: targetView.frame.width - 2, width: 3, height: targetView.frame.height - targetView.frame.width)
        targetView.addSubview(column_view)
        
        column_view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        endAnimateShadow()
    }
    func endAnimateShadow(){
        let shadowSize: CGFloat = 10
        let contactRect = CGRect(x: (self.frame.width - shadowSize) / 2, y: self.height - shadowSize / 2, width: shadowSize, height: shadowSize)
        
        UIView.animate(withDuration: duration / 8, delay: 0.1) {
            self.targetView.transform = .identity
        } completion: { (_) in
            self.layer.shadowPath = UIBezierPath(ovalIn: contactRect).cgPath
            self.layer.shadowOpacity = 0.5
        }
        animateSquare(direction: nil, animate: false)

    }
    
    func startAnimateShadow(direction: Direction){
        let shadowSize: CGFloat = 35
        let contactRect = CGRect(x: (self.frame.width - shadowSize) / 2, y: self.height - shadowSize / 2, width: shadowSize, height: shadowSize)
        
        UIView.animate(withDuration: duration/6) {
            self.targetView.transform = CGAffineTransform(translationX: 0, y: -self.jumpHeight)
            self.layer.shadowPath = UIBezierPath(ovalIn: contactRect).cgPath
            self.layer.shadowRadius = 5
            self.layer.shadowOpacity = 0.2
        }
        animateSquare(direction: direction, animate: true)
    }
    
    func animateSquare(direction: Direction?, animate: Bool){
        
        UIView.animate(withDuration: duration) { [self] in
            if animate {
                let directions = getDirections(direction: direction!)
                inner_square.transform = CGAffineTransform(translationX: directions.x, y: directions.y)
            }else{
                inner_square.transform = .identity
            }
        }
    }
  
    private func getDirections(direction: Direction) -> (x: CGFloat, y: CGFloat) {
        var directions : (x: CGFloat, y: CGFloat) = (0,0)
        switch direction {
        case .Left:
            directions.x = 7
            break
        case .Right:
            directions.x = -7
            break
        case .Up:
            directions.y = 7
            break
        case .Down:
            directions.y = -7
            break
        }
        return directions
    }
    
    // Action Gesture
    
    func handlePan(sender: UIPanGestureRecognizer){
        switch sender.state {
        case .began:
            self.startAnimateShadow(direction: sender.direction!)
            print("bbb")

            break
            
        case .ended:
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Change `2.0` to the desired number of seconds.
                self.endAnimateShadow()
               // Code you want to be delayed
            }
           
            break
        default: break
        }
    }
    
}

