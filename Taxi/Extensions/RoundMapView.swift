//
//  RoundMapView.swift
//  Taxi
//
//  Created by Muhammad Azizullo on 18/06/22.
//

import UIKit
import MapKit

class RoundMapView: MKMapView {

    override func awakeFromNib() {
        setupView()
    }
    
    func setupView() {
        self.layer.cornerRadius = 130
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 10.0
        
    }

}
