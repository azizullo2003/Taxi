//
//  ViewController.swift
//  Taxi
//
//  Created by Muhammad Azizullo on 15/06/22.
//

import UIKit
import FloatingPanel
import Lottie
import SideMenu
import CoreLocation
import MapKit
import Firebase
import Polyline


class ViewController: UIViewController, FloatingPanelControllerDelegate, CLLocationManagerDelegate {
    private let sideMenu = SideMenuNavigationController(rootViewController: SideMenuVC())
    let duration : TimeInterval = 1

    var floatingView = UIView()
    
    var currentUserId = Auth.auth().currentUser?.uid
    
    var firstTextField = UITextField()
    var secondTextField = UITextField()
    
    var tableView = UITableView()
    
    var matchingItems: [MKMapItem] = [MKMapItem]()
    
    var route: MKRoute!
    
    var selectedItemPlacemark: MKPlacemark? = nil
    
    var manager: CLLocationManager?
    
    var regionRadius: CLLocationDistance = 1000
    
    
    lazy var targetView: Target = {
        let target = Target(frame: CGRect(x: (view.frame.width - 46.2) / 2, y: (view.frame.height - 120) / 2, width: 44, height: 66))
    
    return target
}()
    
    var baseCardViewController:BaseFloatingPanel!
    
    var baseCardHeight:CGFloat = 550
    var baseCardHandleAreaHeight:CGFloat = 252.5
    var baseCardVisible = false


    var visualEffectView:UIVisualEffectView!
    var coordinateArray: [CLLocationCoordinate2D] = []

    
    var mapView: MKMapView!

    let menuButton = UIButton()
    
    let views = UIView()
    
    let navButton = UIButton()
    
    let weatherAnimation = AnimationView()
    
    
    var polyline: Polyline?

    var coordinates: [CLLocationCoordinate2D]?
 
    var pointss: String?


    let networkDataFetcher = NetworkDataFetcher()

    var graphopper: GraphopperResponse? = nil
    
    let orderButton = UIButton()
    
    let orderCancelButton = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
       
            mapView = MKMapView(frame: view.bounds)
            mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            mapView.showsUserLocation = true
        
            mapView.setUserTrackingMode(.follow, animated: false)
            //   mapView.styleURL = (URL(string: "mapbox://styles/azizullo2003/cl4dzqoyj000a16pf9ar9qun2/draft"))
            mapView.userTrackingMode = .follow
            mapView.showsCompass = false
            mapView.isRotateEnabled = true
            mapView.tintColor = .gray
            mapView.isPitchEnabled = false
            mapView.userTrackingMode = .follow
            let newCameraPosition = MKMapCamera(lookingAtCenter: mapView.centerCoordinate, fromDistance: 100.0,   pitch: 0.0, heading: -600)
            mapView.camera = newCameraPosition
            view.addSubview(mapView)
       
        orderButton.frame = CGRect(x: 20, y: view.frame.size.height - 100, width: view.frame.size.width - 40, height: 60)
        orderButton.setTitle("Buyurtma berish", for: .normal)
        orderButton.setTitleColor(.white, for: .normal)
        orderButton.backgroundColor = .blue
        orderButton.addTarget(self, action: #selector(orderFunc), for: .touchUpInside)
        view.addSubview(orderButton)
        
        orderCancelButton.frame = CGRect(x: 20, y: view.frame.size.height - 180, width: 100, height: 20)
        orderCancelButton.setTitle("CancelcTrip", for: .normal)
        orderCancelButton.setTitleColor(.white, for: .normal)
        orderCancelButton.backgroundColor = .blue
        orderCancelButton.addTarget(self, action: #selector(orderCancelFunc), for: .touchUpInside)
        view.addSubview(orderCancelButton)
        
        
        
        
        floatingView.frame = CGRect(x: 50, y: 100, width: 250, height: 70)
        floatingView.backgroundColor = .white
        
        firstTextField.frame = CGRect(x: 10, y: 0, width: floatingView.frame.size.width - 10, height: 30)
        firstTextField.text = "My Location"
         
        floatingView.addSubview(firstTextField)
        
        
        secondTextField.frame = CGRect(x: 10, y: 15, width: floatingView.frame.size.width - 10, height: floatingView.frame.size.height)
        secondTextField.placeholder = "Qayerga boramiz?!"
        
        floatingView.addSubview(secondTextField)
        
        secondTextField.clearButtonMode = .always

        
        mapView.addSubview(floatingView)
        
         manager = CLLocationManager()
         manager?.delegate = self
         manager?.desiredAccuracy = kCLLocationAccuracyBest
        
        
            checkLocationAuthStatus()
    
        
            mapView.delegate = self
        secondTextField.delegate = self
        
        DataService.instance.REF_DRIVERS.observe(.value, with: { (snapshot) in
            self.loadDriverAnnotationFromFB()
        })
         
        
     
        
            views.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100)
            let gradient = CAGradientLayer()

            gradient.frame = views.bounds
            gradient.colors = [UIColor.white.cgColor, UIColor.init(white: 1, alpha: 0.0).cgColor]
            gradient.startPoint = CGPoint.zero
            gradient.endPoint = CGPoint(x: 0, y: 1)
            gradient.locations = [0.2, 1.0]
            views.layer.addSublayer(gradient)
          //  mapView.addSubview(views)


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

            mapView.isUserInteractionEnabled = true

            //SideMenu
            sideMenu.leftSide = true
            SideMenuManager.default.leftMenuNavigationController = sideMenu
            sideMenu.completionCurve = .easeIn
        
        
        
        UpdateService.instance.observeTrips { (tripDict) in
            if let tripDict = tripDict {
                let pickupCoordinateArray = tripDict["pickupCoordinate"] as! NSArray
                let tripKey = tripDict["passengerKey"] as! String
                let acceptenceStatus = tripDict["tripIsAccepted"] as! Bool
                
                if acceptenceStatus == false {
                    DataService.instance.driverIsAvailable(key: self.currentUserId!, handler: { (available) in
                        if let available = available {
                            if available == true {
                            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                            let pickupVC = storyboard.instantiateViewController(withIdentifier: "PickupVC") as? PickUpVC
                                pickupVC?.initData(coordinate: CLLocationCoordinate2D(latitude:pickupCoordinateArray[0] as! CLLocationDegrees, longitude: pickupCoordinateArray[1] as! CLLocationDegrees), passengerKey: tripKey)
                            self.present(pickupVC!, animated: true)
                            }
                            
                        }
                    })
                }
            }
        }
    }
        override func viewWillAppear(_ animated: Bool) {
            
            super.viewWillAppear(animated)
            
            DataService.instance.driverIsAvailable(key: self.currentUserId!, handler: { (status) in
                if status == false {
                    DataService.instance.REF_TRIPS.observeSingleEvent(of: .value, with: { (tripSnapshot) in
                        if let tripSnapshot = tripSnapshot.children.allObjects as? [DataSnapshot] {
                            for trip in tripSnapshot {
                                if trip.childSnapshot(forPath: "driverKey").value as? String == self.currentUserId! {
                                    let pickupCoordinateArray = trip.childSnapshot(forPath: "pickupCoordinate").value as! NSArray
                                    let pickupCoordinate = CLLocationCoordinate2D(latitude: pickupCoordinateArray[0] as! CLLocationDegrees, longitude: pickupCoordinateArray[1] as! CLLocationDegrees)
                                    let pickupPlacemark = MKPlacemark(coordinate: pickupCoordinate)
                                    
                                    self.dropPinFor(placemark: pickupPlacemark)
                                    self.searchMapKitForResultWithPolyline(forOriginMapItem: nil,
                                    withDestinationMapItem: MKMapItem(placemark: pickupPlacemark))
                                    
                                }
                            }
                        }
                    })
                }
            })
            
            connectUserAndDriverDorTrip()
            
            DataService.instance.REF_TRIPS.observe(.childRemoved, with: { (removedTripSnapshot) in
                let removedTripDict = removedTripSnapshot.value as? [String: AnyObject]
                if removedTripDict?["driverKey"] != nil {
                    DataService.instance.REF_DRIVERS.child(removedTripDict?["driverKey"] as! String).updateChildValues(["driverIsOnTrip": false])
                }
                DataService.instance.userIsDriver(userKey: self.currentUserId!, handler: { (isDriver) in
                        if isDriver == true {
                            self.removeOverlaysAndAnnotations(forDrivers: false, forPassenger: true)
                        }
                        else {
                            self.orderCancelButton.isHidden = true
                            self.secondTextField.text = ""
                            self.removeOverlaysAndAnnotations(forDrivers: false, forPassenger: true)
                            //remove all map annotations and overlays
                            self.centerMapOnUserLocation()
                            self.secondTextField.isUserInteractionEnabled = true
                        }
                    })
                    
                
            })
        }

    @objc func orderCancelFunc() {
        DataService.instance.driverIsOnTrip(driverKey: currentUserId!) { (isOnTrip, driverKey, tripKey) in
            if isOnTrip == false {
                UpdateService.instance.cancelTrip(withPassengerKey: tripKey!, forDriverKey: driverKey!)
            }
        }
        DataService.instance.passengerIsOnTrip(passengerKey: currentUserId!) { (isOnTrip, driverKey, tripKey) in
            if isOnTrip == true {
                UpdateService.instance.cancelTrip(withPassengerKey: self.currentUserId!, forDriverKey: driverKey!)
                
            }
            else {
                UpdateService.instance.cancelTrip(withPassengerKey: self.currentUserId!, forDriverKey: nil)
            }
        }
        
        
    }
    
    func connectUserAndDriverDorTrip() {
        DataService.instance.userIsDriver(userKey: currentUserId!, handler: { (status) in
            if status == false {
                DataService.instance.REF_TRIPS.child(self.currentUserId!).observe(.value, with: { (tripSnapshot) in
                    let tripDict = tripSnapshot.value as? Dictionary<String, AnyObject>
                    
                    if tripDict?["tripIsAccepted"] as? Bool == true {
                        self.removeOverlaysAndAnnotations(forDrivers: false, forPassenger: true)
                 
                        let driverId = tripDict?["driverKey"] as! String
                        
                        let pickupCoordinateArray = tripDict?["pickupCoordinate"] as! NSArray
                        let pickupCoordinate = CLLocationCoordinate2D(latitude: pickupCoordinateArray[0] as! CLLocationDegrees, longitude: pickupCoordinateArray[1] as! CLLocationDegrees)
                        let pickupPlacemark = MKPlacemark(coordinate: pickupCoordinate)
                        
                        let pickupMapItem = MKMapItem(placemark: pickupPlacemark)
                        
                        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value, with: { [self] (driverSnapshot) in
                            if let driverSnapshot = driverSnapshot.children.allObjects as? [DataSnapshot] {
                                for driver in driverSnapshot {
                                    if driver.key == driverId {
                                        let driverCoordinateArray = driver.childSnapshot(forPath: "coordinate").value as! NSArray
                                        let driverCoordinate = CLLocationCoordinate2D(latitude: driverCoordinateArray[0] as! CLLocationDegrees, longitude: driverCoordinateArray[1] as! CLLocationDegrees)
                                        let driverPlacemark = MKPlacemark(coordinate: driverCoordinate)
                                        
                                        let driverMapItem = MKMapItem(placemark: driverPlacemark)
                                        
                                        let passengerAnnotation = PassengerAnnotation(coordinate: pickupCoordinate, key: currentUserId!)
                                        
                                        let driverAnnotation = DriverAnnotation(coordinate: driverCoordinate, withKey: driverId)
                                        
                                        
                                        
                                        self.mapView.addAnnotation(passengerAnnotation)
                                        
                                        self.searchMapKitForResultWithPolyline(forOriginMapItem: driverMapItem, withDestinationMapItem: pickupMapItem)
                                        orderButton.isUserInteractionEnabled = false
                                    }
                                    
                                }
                                }
                        })
                    }
                })
            }
        })
    }
    // The Pan Gesture
    @objc func orderFunc() {
        UpdateService.instance.updateTripsWithCoordinatedUponRequest()
        self.view.endEditing(true)
        secondTextField.isUserInteractionEnabled = false
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
    
    func centerMapOnUserLocation() {
        let coordinateRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    func loadDriverAnnotationFromFB() {
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let driverSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for driver in driverSnapshot {
                    if driver.hasChild("userIsDriver") {
                        if driver.hasChild("coordinate") {
                            if driver.childSnapshot(forPath: "isPickUpModeEnabled").value as? Bool == true {
                                if let driverDict = driver.value as? Dictionary<String, AnyObject> {
                                    let coordinateArray = driverDict["coordinate"] as! NSArray
                                    let driverCoordinate = CLLocationCoordinate2D(latitude: coordinateArray[0] as! CLLocationDegrees, longitude: coordinateArray[1] as! CLLocationDegrees)
                                    
                                    let annotation = DriverAnnotation(coordinate: driverCoordinate, withKey: driver.key)
                                    var driverIsVisible: Bool {
                                        return self.mapView.annotations.contains(where: { (annotation) -> Bool in
                                            if let driverAnnotation = annotation as? DriverAnnotation {
                                                if driverAnnotation.key == driver.key {
                                                    driverAnnotation.update(annotationPosition: driverAnnotation, withCoordinate: driverCoordinate)
                                                    return true
                                                }
                                            }
                                            return false
                                        })
                                    }
                                    if !driverIsVisible {
                                        self.mapView.addAnnotation(annotation)
                                    }
                                    
                                }
                            } else {
                                for annotation in self.mapView.annotations {
                                    if annotation.isKind(of: DriverAnnotation.self) {
                                        if let annotation = annotation as? DriverAnnotation  {
                                            if annotation.key == driver.key {
                                                self.mapView.removeAnnotation(annotation)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                 
                }
            }
        })
        
    }
    
     
    func checkLocationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            manager = CLLocationManager()
          //  manager?.delegate = self
            manager?.desiredAccuracy = kCLLocationAccuracyBest
            manager?.startUpdatingLocation()
        } else {
            manager?.requestAlwaysAuthorization()
        }
    }
    
   
    
    
    @objc func navigate() {

        DataService.instance.REF_USERS.observeSingleEvent(of: .value) { [self] (snapshot) in
            
            if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for user in userSnapshot {
                    if user.key == self.currentUserId! {
                        if !user.hasChild("userIsDriver") {
                            self.zoom(toFitAnnnotationsFromMapView: self.mapView)
                            navButton.isHidden = true

                        } else {
                            self.centerMapOnUserLocation()
                            navButton.isHidden = true
                        }
                    }
                }
            }
        }
            
        
     //   mapView.showsUserLocation = true

      //  mapView.setUserTrackingMode(.follow, animated: true)

        
        
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
   
    }
    
    func removeOverlaysAndAnnotations(forDrivers: Bool?, forPassenger: Bool?) {
        
        for annotation in mapView.annotations {
            if let annotation = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(annotation)
            }
            if forPassenger! {
                if let annotation = annotation as? PassengerAnnotation {
                    mapView.removeAnnotation(annotation)
                }
            }
            if forDrivers! {
                if let annotation = annotation as? DriverAnnotation {
                    mapView.removeAnnotation(annotation)
                }
            }
        }
        
        for overlay in mapView.overlays {
            if overlay is MKPolygon {
                mapView.removeOverlay(overlay)
            }
        }
        
    }
}
            


extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        UpdateService.instance.updateUserLocation(withCoordinate: userLocation.coordinate)
        UpdateService.instance.updateDriverLocation(withCoordinate: userLocation.coordinate)
        
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let identifier = "driver"
            var view: MKAnnotationView
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.image = UIImage(named: "driverAnnotation")
            return view
        } else if let annotation = annotation as? PassengerAnnotation {
            let identifier = "passenger"
            var view: MKAnnotationView
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.image = UIImage(named: "currentLocationAnnotation")
            return view
        } else if let annotation = annotation as? MKPointAnnotation {
            let identifier = "destination"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                annotationView?.annotation = annotation
            }
            annotationView?.image = UIImage(named: "destinationAnnotation")
            return annotationView
        }
        
        return nil
        
     
    }
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            navButton.isHidden = false

    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKPolyline.self){
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
                polylineRenderer.fillColor = UIColor.red
                polylineRenderer.strokeColor = UIColor.red
                polylineRenderer.lineWidth = 5
            
            zoom(toFitAnnnotationsFromMapView: self.mapView)
            polylineRenderer.lineCap = .round
            
            return polylineRenderer
     }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func performSearch() {
        matchingItems.removeAll()
        let request = MKLocalSearch.Request()
        
        request.naturalLanguageQuery = secondTextField.text
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            if error != nil {
                print(error.debugDescription)
            } else if response!.mapItems.count == 0 {
                print("no results!")
            } else {
                for mapItem in response!.mapItems {
                    self.matchingItems.append(mapItem as MKMapItem)
                    self.tableView.reloadData()
                    self.shouldPresentLoadingView(false)
                }
            }
        }
    }
    
    func dropPinFor(placemark: MKPlacemark) {
        selectedItemPlacemark = placemark
        for annotation in mapView.annotations {
            if annotation.isKind(of: MKAnnotation.self) {
                mapView.removeAnnotation(annotation)
            }
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        mapView.addAnnotation(annotation)
        
    }
    
    func searchMapKitForResultWithPolyline(forOriginMapItem originMapItem: MKMapItem?, withDestinationMapItem destinationMapItem: MKMapItem) {
        var coordination = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        if originMapItem == nil  {
            coordination.latitude = mapView.userLocation.coordinate.latitude
            coordination.longitude = mapView.userLocation.coordinate.longitude
        } else {
            coordination.latitude = (originMapItem?.placemark.coordinate.latitude)!
            coordination.longitude = (originMapItem?.placemark.coordinate.longitude)!
        }
       
        let blat = destinationMapItem.placemark.coordinate.latitude
        let blon = destinationMapItem.placemark.coordinate.longitude
      
        let urlString = "http://navi.uz.taxi:8989/route?point=\(coordination.latitude)%2C\(coordination.longitude)&point=\(blat)%2C\(blon)&type=json&locale=ru&key=&elevation=false&profile=car"
            networkDataFetcher.fetchTracks(urlString: urlString) { [self] (graphopper) in
                guard let graphopper = graphopper else {
                    return
                }
            self.graphopper = graphopper
                
                let fullNameArr = graphopper.paths[0]
                _ = graphopper.paths[0].distance
        
                pointss = fullNameArr.points
               
                func decodePolyline(){
                
                    guard let pointss = pointss else {return}
                    polyline = Polyline(encodedPolyline: pointss)
                    coordinates = polyline?.coordinates
            }
            
                decodePolyline()
        
                coordinateArray = (coordinates)!
                
                let polygon = MKPolyline(coordinates: coordinateArray, count: coordinateArray.count)
                self.mapView.addOverlay(polygon)
                let delegate = AppDelegate.getAppDelegate()
                
                delegate.window?.rootViewController?.shouldPresentLoadingView(false)
                
            }
        
    }
    
    func zoom(toFitAnnnotationsFromMapView mapView: MKMapView) {
        if mapView.annotations.count == 0 {
            return
        }
        var topLeftCoordinate = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRightCoordinate = CLLocationCoordinate2D(latitude: 90, longitude: -180)
        
        for annotation in mapView.annotations where !annotation.isKind(of: DriverAnnotation.self) {
            topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, annotation.coordinate.longitude)
            topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, annotation.coordinate.latitude)
            bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, annotation.coordinate.longitude)
            bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, annotation.coordinate.latitude)
            
        }
        var region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(topLeftCoordinate.latitude - (topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 0.5, topLeftCoordinate.longitude + (bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 0.5), span: MKCoordinateSpan(latitudeDelta: fabs(topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 2.0, longitudeDelta: fabs(bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 2.0))
     
        region = mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
    }
    
}
extension ViewController: UITextFieldDelegate {
     func textFieldDidBeginEditing(_ textField: UITextField) {
        
         if textField == secondTextField {
         
        tableView.frame = CGRect(x: 20, y: view.frame.size.height, width: view.frame.size.height - 40, height: view.frame.size.height - 170)
        tableView.layer.cornerRadius = 5.0
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "locationCell")
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
        tableView.tag = 18
        
        tableView.rowHeight = 60
        
        view.addSubview(tableView)
             animateTabelView(shouldShow: true)
         }
         
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == secondTextField {
            performSearch()
            shouldPresentLoadingView(true)
            view.endEditing(true)
        }
        return true
        
    }
    func textFieldDidEditingtextFieldDidEndEditing(_ textField: UITextField) {
        
   
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        matchingItems = []
        tableView.reloadData()

        
        
        DataService.instance.REF_USERS.child(currentUserId!).child("tripCoordinate").removeValue()
        
        mapView.removeOverlays(mapView.overlays)
        for annotation in mapView.annotations {
            if let annotation = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(annotation)
            }
            else if annotation.isKind(of: PassengerAnnotation.self) {
                mapView.removeAnnotation(annotation)
            }
        }
        centerMapOnUserLocation()
        return true
    }
    func animateTabelView(shouldShow: Bool) {
        if shouldShow {
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.frame = CGRect(x: 20, y: 170, width: self.view.frame.size.height - 40, height: self.view.frame.size.height - 170)
                
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.frame = CGRect(x: 20, y: self.view.frame.size.height, width: self.view.frame.size.width - 40, height: self.view.frame.size.height - 170)
            }, completion: { (finished) in
                for subview in self.view.subviews {
                    if subview.tag == 18 {
                        subview.removeFromSuperview()
                    }
                }
                
                
            })
        }
    }
}

extension ViewController: UITableViewDelegate
, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "locationCell")
        let mapItem = matchingItems[indexPath.row]
        cell.textLabel?.text = mapItem.name
        cell.detailTextLabel?.text = mapItem.placemark.title
        return cell
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        shouldPresentLoadingView(true)
        let passengerCoordinate = manager?.location?.coordinate
        
        let passengerAnnotation = PassengerAnnotation(coordinate: passengerCoordinate!, key: currentUserId!)
        
        mapView.addAnnotation(passengerAnnotation)
        secondTextField.text = tableView.cellForRow(at: indexPath)?.textLabel?.text
        
        let selectedMapItem = matchingItems[indexPath.row]
        DataService.instance.REF_USERS.child(currentUserId!).updateChildValues(["tripCoordinate": [selectedMapItem.placemark.coordinate.latitude, selectedMapItem.placemark.coordinate.longitude]])
        dropPinFor(placemark: selectedMapItem.placemark)
        
        searchMapKitForResultWithPolyline(forOriginMapItem: nil, withDestinationMapItem: selectedMapItem)
        
        animateTabelView(shouldShow: false)
        
        print("selected")
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if secondTextField.text == "" {
            animateTabelView(shouldShow: false)
    }
}
    
}
