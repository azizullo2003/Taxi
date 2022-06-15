//
//  ViewController.swift
//  Taxi
//
//  Created by Muhammad Azizullo on 15/06/22.
//

import UIKit
import Mapbox
import FloatingPanel
import Lottie
import SideMenu

class ViewController: UIViewController {
    private let sideMenu = SideMenuNavigationController(rootViewController: SideMenuVC())

    
    var mapView: MGLMapView!

    let button = UIButton()
    
    let views = UIView()
    
    let navButton = UIButton()
    
    let weatherAnimation = AnimationView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
           
            mapView = MGLMapView(frame: view.bounds)
            mapView.automaticallyAdjustsContentInset = false
            mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            mapView.showsUserLocation = true
            mapView.setUserTrackingMode(.follow, animated: false, completionHandler: nil)
            mapView.styleURL = (URL(string: "mapbox://styles/azizullo2003/cl4dzqoyj000a16pf9ar9qun2/draft"))
            mapView.compassView.compassVisibility = .hidden
            mapView.userTrackingMode = .follow
            mapView.showsUserHeadingIndicator = true
            mapView.isRotateEnabled = true
            mapView.tintColor = .gray
            mapView.isPitchEnabled = false
           let newCameraPosition = MGLMapCamera(lookingAtCenter: mapView.centerCoordinate, altitude: 0.0, pitch: 0.0, heading: -300)
           mapView.allowsRotating = false
           mapView.camera = newCameraPosition
           mapView.zoomLevel = 15
           view.addSubview(mapView)

        views.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100)
        let gradient = CAGradientLayer()

        gradient.frame = views.bounds
        gradient.colors = [UIColor.white.cgColor, UIColor.init(white: 1, alpha: 0.0).cgColor]
        gradient.startPoint = CGPoint.zero
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.locations = [0.2, 1.0]
        views.layer.addSublayer(gradient)
       // mapView.addSubview(views)

        
        //button
        button.frame = CGRect(x: 15, y: 60, width: 30, height: 30)
        button.setImage(UIImage(named:"icons8-menu-60"), for: .normal)
        button.addTarget(self, action: #selector(openSideMenu), for: .touchUpInside)
        mapView.addSubview(button)
        
        //navbutton
        let uiview = UIImageView()
        let image = UIImage(named: "icons8-navigation-64")
        uiview.frame = CGRect(x: 10, y: 12, width: 27, height: 27)
        uiview.image = image
      
        navButton.frame = CGRect(x: 15, y: 450, width: 50, height: 50)
        navButton.backgroundColor = .white
        navButton.layer.cornerRadius = 25
        navButton.addTarget(self, action: #selector(navigate), for: .touchUpInside)
        navButton.addSubview(uiview)
      //  mapView.addSubview(navButton)
        
        //animation
        weatherAnimation.frame = CGRect(x: 320, y: 50, width: 48, height: 48)
        weatherAnimation.contentMode = .scaleAspectFit
        weatherAnimation.animation = Animation.named("sunny")
        weatherAnimation.loopMode = .loop
        weatherAnimation.play()
        mapView.addSubview(weatherAnimation)
        
        //SideMenu
        sideMenu.leftSide = true
        SideMenuManager.default.leftMenuNavigationController = sideMenu

            
    }
    
    @objc func navigate() {

        mapView.setUserTrackingMode(.follow, animated: true, completionHandler: nil)
      //  mapView.showsUserLocation = true
        
        mapView.zoomLevel = 15
        
    }
    @objc func openSideMenu() {
        
        present(sideMenu, animated: true)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        view.addSubview(navButton)
    }



}
