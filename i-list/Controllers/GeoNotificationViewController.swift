//
//  GeoNotificationViewController.swift
//  i-list
//
//  Created by Abdullah  Ali Shah on 17/04/2018.
//  Copyright © 2018 Abdullah  Ali Shah. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications

class GeoNotificationViewController: UIViewController {
    
    //MARK:- Properties
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var categories = [Category]()
    @IBOutlet weak var radiusSliderOutlet: UISlider!
    @IBOutlet weak var radiusValueLabel: UILabel!
    var locationReceiver = Bool()
    var notificationTitle = ""
    
    //..........................................
    @IBAction func radiusSlider(_ sender: Any) {
        radiusValueLabel.text = String(describing: radiusSliderOutlet.value)
    }
    
    //MARK:- View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert , .sound , .badge ]) { (granted, error) in
            //
        }
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Add Region Function
    
    @IBAction func addRegion(_ sender: UILongPressGestureRecognizer) {
        print("Add Region")
        guard let longPress = sender as? UILongPressGestureRecognizer else { return }
        let touchLocation = longPress.location(in: mapView)
        let coordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        let region = CLCircularRegion(center: coordinate, radius: CLLocationDistance(radiusSliderOutlet.value), identifier: notificationTitle)
        mapView.removeOverlays(mapView.overlays)
        locationManager.startMonitoring(for: region)
        let circle = MKCircle(center: coordinate, radius: region.radius)
        mapView.add(circle)
    }
    
    //MARK:- Notification Settings
    
    func showNotification(title: String, message: String ){
        let content = UNMutableNotificationContent()
        content.title = notificationTitle
        content.body = "You have been notified for the geotification for \(notificationTitle)"
        content.badge = 1
        content.sound = .default()
        let request = UNNotificationRequest(identifier: notificationTitle, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    //MARK:- Other Functions
    
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        showNotification(title: "", message: "")
    }
    
    
    @IBAction func segmentControlAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            locationReceiver = true
        case 1:
            locationReceiver = false
        default:
            break
        }
    }
    
}


//MARK:- Location Manager Delegate

extension GeoNotificationViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //locationManager.stopUpdatingLocation()
        mapView.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if locationReceiver == true {
        showNotification(title: "You have entered the marked location", message: "Yay!!")
            print("You entered region")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if locationReceiver == false {
        showNotification(title: "You have exited the marked location", message: "Oww!!")
            print("You exited region")
        }
    }
}

//MARK:- MKMap View Delegate

extension GeoNotificationViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circleOverlay = overlay as? MKCircle else {return MKOverlayRenderer()}
        let circleRenderer = MKCircleRenderer(circle: circleOverlay)
        circleRenderer.strokeColor = .red
        circleRenderer.fillColor = .white
        circleRenderer.alpha = 0.5
        return circleRenderer
    }
}
