//
//  UIViewControllerExt.swift
//  Taxi
//
//  Created by Muhammad Azizullo on 18/06/22.
//

import Foundation
import UIKit


extension UIViewController {
    func shouldPresentLoadingView(_ status: Bool) {
        var fadeView: UIView?
        if status == true {
            fadeView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
            fadeView?.backgroundColor = UIColor.black
            fadeView?.alpha = 0.0
            fadeView?.tag = 99
            
            let spinner = UIActivityIndicatorView()
            
            spinner.color = UIColor.white
            spinner.style = UIActivityIndicatorView.Style.large
            spinner.center = view.center

            view.addSubview(fadeView!)
            fadeView?.addSubview(spinner)
            
            spinner.startAnimating()
            
            
        }
        else {
            for subview in view.subviews {
               if subview.tag == 99 {
                   UIView.animate(withDuration: 0.2, animations: {
                       subview.alpha = 0.0
                   }, completion: { (finished) in
                       subview.removeFromSuperview()
                   })
                   
                }
            }
        }
        
        
    }
}
