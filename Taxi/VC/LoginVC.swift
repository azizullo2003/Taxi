//
//  LoginVC.swift
//  Taxi
//
//  Created by Muhammad Azizullo on 16/06/22.
//

import UIKit
import Firebase


class LoginVC: UIViewController, UITextFieldDelegate, Alertable {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()

        emailField.delegate = self
        passwordField.delegate = self
        
        
    }
       

       func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           self.view.endEditing(true)
           return false
       }
   

    @IBAction func authButtonPressed(_ sender: UIButton) {
        
        if emailField.text != nil && passwordField.text != nil {
            self.view.endEditing(true)
            
            if let email = emailField.text, let password = passwordField.text {
                Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                    if error == nil {
                        if let user = user {
                            if self.segmentControl.selectedSegmentIndex == 0 {
                                let userData = ["provider": user.user.providerID] as [String: Any]
                                DataService.instance.createFirebaseDBUser(uid: user.user.uid, userData: userData, isDriver: false)
                            } else {
                                let userData = ["provider": user.user.providerID, USER_IS_DRIVER: true, ACCOUNT_PICKUP_MODE_ENABLED: false, DRIVER_IS_ON_TRIP: false] as [String: Any]
                                DataService.instance.createFirebaseDBUser(uid: user.user.uid, userData: userData, isDriver: true)
                            }
                        }
                        print("Email success")
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        
                        
                        Auth.auth().createUser(withEmail: email, password: password, completion: { [self] (user, error) in
                            if error != nil {
                                print("error")
                            } else {
                                if let user = user {
                                    if self.segmentControl.selectedSegmentIndex == 0 {
                                        let userData = ["provider": user.user.providerID] as [String: Any]
                                        DataService.instance.createFirebaseDBUser(uid: user.user.uid, userData: userData, isDriver: false)
                                    } else {
                                        let userData = ["provider": emailField.text!, USER_IS_DRIVER: true, ACCOUNT_PICKUP_MODE_ENABLED: false, DRIVER_IS_ON_TRIP: false] as [String: Any]
                                        DataService.instance.createFirebaseDBUser(uid: user.user.uid, userData: userData, isDriver: true)
                                    }
                                }
                                self.dismiss(animated: true, completion: nil)
                            }
                        })
                    }
                })
            }
            
        }
   
    }

    }


