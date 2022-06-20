//
//  BaseFloatingPanel.swift
//  Taxi
//
//  Created by Muhammad Azizullo on 15/06/22.
//

import UIKit

class BaseFloatingPanel: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    @objc func handlePan(sender: UIPanGestureRecognizer){
        switch sender.state {
       
        case .ended:
            
print("works")
            break
        default: break
        }
        }
      



}
