//
//  SideMenuVC.swift
//  Taxi
//
//  Created by Muhammad Azizullo on 15/06/22.
//

import UIKit
import Firebase

class SideMenuVC: UIViewController {

    
    let currentUserId = Auth.auth().currentUser?.uid

    
    @IBOutlet weak var userEmailLbl: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userAccountTypeLbl: UILabel!
    @IBOutlet weak var LoginOutButton: UIButton!
    @IBOutlet weak var pickUpModeSwitch: UISwitch!
    @IBOutlet weak var pickUpModeLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

    }


    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pickUpModeSwitch.isOn = false
        pickUpModeSwitch.isHidden = true
        pickUpModeLbl.isHidden = true
        
        observePassengersAndDrivers()
        
        if Auth.auth().currentUser == nil {
            userEmailLbl.text = ""
            userAccountTypeLbl.text = ""
            userImageView.isHidden = true
            LoginOutButton.setTitle(MSG_SIGN_UP_SIGN_IN, for: .normal)
        } else {
            userEmailLbl.text = Auth.auth().currentUser?.email
            userAccountTypeLbl.text = ""
            userImageView.isHidden = false
            LoginOutButton.setTitle(MSG_SIGN_OUT, for: .normal)
        }
    }
    
    func observePassengersAndDrivers() {
        DataService.instance.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if snap.key == Auth.auth().currentUser?.uid {
                        self.userAccountTypeLbl.text = ACCOUNT_TYPE_PASSENGER
                    }
                }
            }
        })
        
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if snap.key == Auth.auth().currentUser?.uid {
                        self.userAccountTypeLbl.text = ACCOUNT_TYPE_DRIVER
                        self.pickUpModeSwitch.isHidden = false
                        
                        let switchStatus = snap.childSnapshot(forPath: ACCOUNT_PICKUP_MODE_ENABLED).value
                        
                        if switchStatus as! Int == 0 {
                            self.pickUpModeSwitch.isOn = false

                        }
                        else if switchStatus as! Int == 1 {
                            self.pickUpModeSwitch.isOn = true

                        }
                        self.pickUpModeLbl.isHidden = false
                    }
                }
            }
        })
    }
    
    @IBAction func switchWasToggled(_ sender: Any) {
        if pickUpModeSwitch.isOn {
            pickUpModeLbl.text = MSG_PICKUP_MODE_ENABLED
         
            DataService.instance.REF_DRIVERS.child(currentUserId!).updateChildValues([ACCOUNT_PICKUP_MODE_ENABLED: true])
        } else {
            pickUpModeLbl.text = MSG_PICKUP_MODE_DISABLED

            DataService.instance.REF_DRIVERS.child(currentUserId!).updateChildValues([ACCOUNT_PICKUP_MODE_ENABLED: false])
        }
    }

    @IBAction func signUpLoginBtnWasPressed(_ sender: Any) {
        if Auth.auth().currentUser == nil {
           
            let loginVC = LoginVC()
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true, completion: nil)
        } else {
            do {
                try Auth.auth().signOut()
                userEmailLbl.text = ""
                userAccountTypeLbl.text = ""
                userImageView.isHidden = true
                pickUpModeLbl.text = ""
                pickUpModeSwitch.isHidden = true
                LoginOutButton.setTitle(MSG_SIGN_UP_SIGN_IN, for: .normal)
            } catch (let error) {
                print(error)
            }
        }
    }
   

}
