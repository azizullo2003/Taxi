//
//  DriverAnnotation.swift
//  Taxi
//
//  Created by Muhammad Azizullo on 17/06/22.
//

import Foundation
import MapKit
import UIKit

class DriverAnnotation: NSObject, MKAnnotation {
    
    dynamic var coordinate: CLLocationCoordinate2D
    var key: String
    
    init(coordinate: CLLocationCoordinate2D, withKey key: String) {
        self.coordinate = coordinate
        self.key = key
        super.init()
        
    }
    func update(annotationPosition annotation: DriverAnnotation, withCoordinate coordinate: CLLocationCoordinate2D) {
        var location = self.coordinate
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        self.coordinate = location
        UIView.animate(withDuration: 0.2) {
            self.coordinate = location
            
        }
        
    }
    
}
