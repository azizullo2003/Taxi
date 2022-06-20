//
//  Alertable.swift
//  Taxi
//
//  Created by Muhammad Azizullo on 18/06/22.
//

import Foundation
import UIKit

protocol Alertable {}

extension Alertable where Self: UIViewController {
    func showAlert(_ msg: String) {
        
        let alertController = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
        
        
    }
}
