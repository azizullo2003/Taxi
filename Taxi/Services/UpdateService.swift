//
//  UpdateService.swift
//  Taxi
//
//  Created by Muhammad Azizullo on 17/06/22.
//

import Foundation
import UIKit
import Firebase
import MapKit


class UpdateService {
    static var instance = UpdateService()
    func updateUserLocation(withCoordinate coordinate: CLLocationCoordinate2D) {
        DataService.instance.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for user in userSnapshot {
                    if user.key == Auth.auth().currentUser?.uid {
                        DataService.instance.REF_USERS.child(user.key).updateChildValues(["coordinate": [coordinate.latitude, coordinate.longitude]])
                    }
                }
            }
            
        })
    }
    func updateDriverLocation(withCoordinate coordinate: CLLocationCoordinate2D) {
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let driverSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for driver in driverSnapshot {
                    if driver.key == Auth.auth().currentUser?.uid {
                        if driver.childSnapshot(forPath: "isPickUpModeEnabled").value as? Bool == true {
                            DataService.instance.REF_DRIVERS.child(driver.key).updateChildValues(["coordinate": [coordinate.latitude, coordinate.longitude]])
                        }
                        
                    }
                }
            }
        })
    }
    
    func observeTrips(handler: @escaping(_ coordinateDict: Dictionary<String, AnyObject>?) -> Void) {
        DataService.instance.REF_TRIPS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let tripSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for trip in tripSnapshot {
                    if trip.hasChild("passengerKey") && trip.hasChild("tripIsAccepted") {
                        if let tripDict = trip.value as? Dictionary<String, AnyObject> {
                            handler(tripDict)
                        }
                    }
                }
            }
        })
    }
    
    func updateTripsWithCoordinatedUponRequest() {
        DataService.instance.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for user in userSnapshot {
                    if user.key == Auth.auth().currentUser?.uid {
                        if !user.hasChild("userIsDriver") {
                            
                            if let userDict = user.value as? Dictionary<String, AnyObject> {
                                let pickupArray = userDict["coordinate"] as! NSArray
                                let destionationArray = userDict["tripCoordinate"] as! NSArray
                                
                                DataService.instance.REF_TRIPS.child(user.key).updateChildValues(["pickupCoordinate": [pickupArray[0], pickupArray[1]], "destionationCoordinate": [destionationArray[0], destionationArray[1]], "passengerKey": user.key, "tripIsAccepted": false])
                                
                                DataService.instance.REF_TRIPS.child(user.key).updateChildValues(["destionationCoordinate": [destionationArray[0], destionationArray[1]]])
                                DataService.instance.REF_TRIPS.child(user.key).updateChildValues(["passengerKey": user.key])
                                DataService.instance.REF_TRIPS.child(user.key).updateChildValues(["tripIsAccepted": false])
                             }
                        }
                    }
                }
            }
        })
        
    }
    
    func acceptTrip(withPassengerKey passengerKey: String, forDriverKey driverKey: String) {
        
        DataService.instance.REF_TRIPS.child(passengerKey).updateChildValues(["driverKey": driverKey,"tripIsAccepted": true])
        DataService.instance.REF_DRIVERS.child(driverKey).updateChildValues(["driverIsOnTrip": true])
        
    }
    
    func cancelTrip(withPassengerKey passengerKey: String, forDriverKey  driverKey: String?) {
        
        DataService.instance.REF_TRIPS.child(passengerKey).removeValue()
        DataService.instance.REF_USERS.child(passengerKey).child("tripCoordinate").removeValue()
        if driverKey != nil {
            DataService.instance.REF_DRIVERS.child(driverKey!).updateChildValues(["driverIsOnTrip": false])

        }
        
    }
        
}
