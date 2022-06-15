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

class ViewController: UIViewController, FloatingPanelControllerDelegate {
    private let sideMenu = SideMenuNavigationController(rootViewController: SideMenuVC())
    let duration : TimeInterval = 1

    lazy var targetView: Target = {
        let target = Target(frame: CGRect(x: (view.frame.width - 46.2) / 2, y: (view.frame.height - 120) / 2, width: 44, height: 66))
    
    return target
}()
    
    var baseCardViewController:BaseFloatingPanel!
    
    var baseCardHeight:CGFloat = 550
    var baseCardHandleAreaHeight:CGFloat = 252.5
    var baseCardVisible = false


    var visualEffectView:UIVisualEffectView!
    
    
    var mapView: MGLMapView!

    let menuButton = UIButton()
    
    let views = UIView()
    
    let navButton = UIButton()
    
    let weatherAnimation = AnimationView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
            setupCard()

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
            mapView.userTrackingMode = .follow
            mapView.showsUserHeadingIndicator = true
            let newCameraPosition = MGLMapCamera(lookingAtCenter: mapView.centerCoordinate, altitude: 0.0,   pitch: 0.0, heading: -300)
            mapView.allowsRotating = false
            mapView.camera = newCameraPosition
            mapView.zoomLevel = 15
            view.addSubview(mapView)
            view.addSubview(baseCardViewController.view)


            views.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100)
            let gradient = CAGradientLayer()

            gradient.frame = views.bounds
            gradient.colors = [UIColor.white.cgColor, UIColor.init(white: 1, alpha: 0.0).cgColor]
            gradient.startPoint = CGPoint.zero
            gradient.endPoint = CGPoint(x: 0, y: 1)
            gradient.locations = [0.2, 1.0]
            views.layer.addSublayer(gradient)
            mapView.addSubview(views)


            //button
            menuButton.frame = CGRect(x: 15, y: 60, width: 30, height: 30)
            menuButton.setImage(UIImage(named:"icons8-menu-60"), for: .normal)
            menuButton.addTarget(self, action: #selector(openSideMenu), for: .touchUpInside)
            view.addSubview(menuButton)
        
            //navbutton
            let uiview = UIImageView()
            let image = UIImage(named: "icons8-navigation-64")
            uiview.frame = CGRect(x: 13, y: 15, width: 20, height: 20)
            uiview.image = image
      
        navButton.frame = CGRect(x: 12, y: view.frame.size.height - baseCardHandleAreaHeight - 70, width: 48, height: 48)
            navButton.backgroundColor = .white
            navButton.layer.cornerRadius = 25
            navButton.addTarget(self, action: #selector(navigate), for: .touchUpInside)
            navButton.layer.shadowColor = UIColor.gray.cgColor
            navButton.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
            navButton.layer.shadowOpacity = 0.2
            navButton.layer.shadowRadius = 4
            navButton.addSubview(uiview)
            view.addSubview(navButton)
        
            //animation
            weatherAnimation.frame = CGRect(x: 320, y: 50, width: 48, height: 48)
            weatherAnimation.contentMode = .scaleAspectFit
            weatherAnimation.animation = Animation.named("sunny")
            weatherAnimation.loopMode = .loop
            weatherAnimation.play()
            view.addSubview(weatherAnimation)

        
            //SideMenu
            sideMenu.leftSide = true
            SideMenuManager.default.leftMenuNavigationController = sideMenu
            sideMenu.completionCurve = .easeIn

        

   addPanGestureRecognizer()
    }
    private func addPanGestureRecognizer(){
        for gesture in mapView.gestureRecognizers!{
            if let _ = gesture as? UIPanGestureRecognizer {
               
                gesture.addTarget(self, action: #selector(handlePan(_:)))
              
            }
        }
    
    }
    
    @objc func handlePan( _ sender: UIPanGestureRecognizer) {
        
        baseCardViewController.handlePan(sender: sender)
        targetView.handlePan(sender: sender)
        switch sender.state {
        case .began:
           
            menuButton.isHidden = true
            weatherAnimation.isHidden = true


            UIView.animate(withDuration: duration/8) {
                self.navButton.transform = CGAffineTransform(translationX: -75, y: 0)
                self.baseCardViewController.view.transform = CGAffineTransform(translationX: 0, y: self.baseCardHandleAreaHeight - 50 )
            }
            break
        case .changed:

            break
        case .ended:
            menuButton.isHidden = false
            weatherAnimation.isHidden = false

           
        //Reverse coordinate to String address
            
            
           
            UIView.animate(withDuration: duration/4) { [self] in

            self.navButton.transform = CGAffineTransform(translationX: 0, y: 0)
            }
            UIView.animate(withDuration: duration/4) { [self] in
                self.baseCardViewController.view.transform = CGAffineTransform(translationX: 0, y: 0)
            
            }
            break
        default: break
        }
    }
    
    
    @objc func navigate() {

        mapView.setUserTrackingMode(.follow, animated: true, completionHandler: nil)
        mapView.showsUserLocation = true
        
        mapView.zoomLevel = 15
        
    }
    @objc func openSideMenu() {
       
       
        present(sideMenu, animated: true)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    func setupCard() {
            visualEffectView = UIVisualEffectView()
            visualEffectView.frame = self.view.frame
            self.view.addSubview(visualEffectView)
            
            baseCardViewController = BaseFloatingPanel(nibName:"BaseFloatingPanel", bundle:nil)
            self.addChild(baseCardViewController)
            self.view.addSubview(baseCardViewController.view)

            self.baseCardViewController.view.layer.cornerRadius = 30
            
            baseCardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - baseCardHandleAreaHeight, width: self.view.bounds.width, height: baseCardHeight)
            
            baseCardViewController.view.clipsToBounds = true
    
        ///
        ///
        ///
   
    }
}
            
