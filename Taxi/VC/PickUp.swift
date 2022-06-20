//
//  PickUp.swift
//  Taxi
//
//  Created by Muhammad Azizullo on 18/06/22.
//

import UIKit
import MapKit
import Firebase

class PickUpVC: UIViewController {

    @IBOutlet weak var picjupMapView: RoundMapView!
    
    var pickupCordinate: CLLocationCoordinate2D!
    
    var passengerKey: String!
    
    var regionRadius: CLLocationDistance = 2000
    var pin: MKPlacemark? = nil
    
    var locationPlacemark: MKPlacemark!
    
    var currentUserId = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()

        picjupMapView.delegate = self
        
        locationPlacemark = MKPlacemark(coordinate: pickupCordinate)
        
        dropPinFor(placemark: locationPlacemark)
        
        centerMapOnLocation(location: locationPlacemark.location!)
        DataService.instance.REF_TRIPS.child(passengerKey).observeSingleEvent(of: .value, with: { (tripSnapshot) in
            if tripSnapshot.exists() {
                if tripSnapshot.childSnapshot(forPath: "tripIsAccepted").value as? Bool == true {
                    self.dismiss(animated: true, completion: nil)
                }
                //check for acceptence
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
            
        })
        
    }
    
    func initData(coordinate: CLLocationCoordinate2D, passengerKey: String) {
        self.pickupCordinate = coordinate
        self.passengerKey = passengerKey
    }
    

   
    @IBAction func acceptTripBtnPressed(_ sender: UIButton) {
        UpdateService.instance.acceptTrip(withPassengerKey: passengerKey, forDriverKey: currentUserId!)
        presentationController?.presentingViewController.shouldPresentLoadingView(true)
        
    }
    
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
}

extension PickUpVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "pickupPoint"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            annotationView?.annotation = annotation
            
        }
        annotationView?.image = UIImage(named: "destinationAnnotation")
        
        return annotationView
    }
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        picjupMapView.setRegion(coordinateRegion, animated: true)
        
    }
    func dropPinFor(placemark: MKPlacemark) {
        pin = placemark
        
        for annotation in picjupMapView.annotations {
            picjupMapView.removeAnnotation(annotation)
            
        }
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = placemark.coordinate
            
            picjupMapView.addAnnotation(annotation)
        
    }
}
