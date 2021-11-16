//
//  PlayController.swift
//  runners
//
//  Created by 최준혁 on 2018. 9. 13..
//  Copyright © 2018년 choirates. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class PlayController:UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var map_view: UIView!
    
    @IBOutlet weak var initial_count_view: UILabel!
    @IBOutlet weak var initial_count_root_view: UIView!
    
    @IBOutlet weak var count_view: UILabel!
    @IBOutlet weak var count_root_view: UIView!
    
    @IBOutlet weak var repeat_view: UILabel!
    @IBOutlet weak var repeat_root_view: UILabel!
    
    @IBOutlet weak var status_view: UILabel!
    @IBOutlet weak var status_root_view: UIView!
    
    @IBOutlet weak var speed_view: UILabel!
    @IBOutlet weak var speed_root_view: UIView!
    
    @IBOutlet weak var speed_guage: UIImageView!
    @IBOutlet weak var speed_guage_root_view: UIView!
    
    @IBAction func stop_button(_ sender: Any) {
        
        self.killInitialTimer()
        self.killTimer()
        
        let preferences = UserDefaults.standard
        
        if(preferences.string(forKey: "repeat") != nil){
            preferences.removeObject(forKey: "repeat")
            preferences.removeObject(forKey: "pointAmount")
            preferences.removeObject(forKey: "time")
            preferences.removeObject(forKey: "distance")
            preferences.removeObject(forKey: "bonus")
            preferences.removeObject(forKey: "speed")
        }
        
        preferences.set(self.repeatCount, forKey: "repeat")
        preferences.set(self.pointAmount, forKey: "pointAmount")
        preferences.set(self.runTime, forKey: "time")
        preferences.set(self.distanceAmount, forKey: "distance")
        preferences.set(self.bonusTime, forKey: "bonus")
        preferences.set(self.speed, forKey: "speed")
        preferences.synchronize()
        
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "PlayResult", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "PlayResultController")
        self.present(newViewController, animated: true, completion: nil)
        
    }
    @IBOutlet weak var stop_root_view: UIStackView!
    
    var locationManager = CLLocationManager()
    
    var mapView : GMSMapView?
    var circle : GMSCircle?
    
    var standardKey = 0
    var amountKey = 0
    var startKey = 0
    
    var standardLatitude : Double?
    var standardLongitude : Double?
    
    var amountLatitude : Double?
    var amountLongitude : Double?
    
    var secondRemaining = 0
    
    var initTimer: Timer?
    var timer: Timer?
    
    var repeatCount = 0
    var pointAmount = 0
    var runTime = 0
    var bonusTime = 0
    var distanceAmount = 0
    var speed = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let camera = GMSCameraPosition.camera(withLatitude: 28.7041, longitude: 77.1025, zoom: 20.0)
        
        mapView = GMSMapView.map(withFrame:self.view.frame, camera: camera)
        mapView?.isMyLocationEnabled = true
        mapView?.delegate = self
        
        //Location Manager code to fetch current location
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
        self.view.addSubview(mapView!)
        self.view.bringSubview(toFront: initial_count_root_view)
        
        startInitialTimer()
        
    }
    
    //Location Manager delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude:(location?.coordinate.longitude)!, zoom:17.7)
        mapView?.animate(to: camera)
        
        //Finally stop updating location otherwise it will come again and again in this delegate
        /*self.locationManager.stopUpdatingLocation()*/
        /* startUpdatingLocation?? */
        
    if(startKey == 1){
            
        if(standardKey == 0){
            standardLatitude = location?.coordinate.latitude
            standardLongitude = location?.coordinate.longitude
            
            makeCircle(latitude: standardLatitude!, longitude: standardLongitude!)
            standardKey = 1
            
        }else{
            
            let distanceMeters = CLLocation(latitude: standardLatitude!, longitude: standardLongitude!).distance(from: location!)
            if(distanceMeters > 100){
                standardLatitude = location?.coordinate.latitude
                standardLongitude = location?.coordinate.longitude
                
                removeCircle()
                makeCircle(latitude: standardLatitude!, longitude: standardLongitude!)
            }
            
        }
        
        //DISTANCE & SPEED
        if(amountKey == 0){
            amountLatitude = location?.coordinate.latitude
            amountLongitude = location?.coordinate.longitude
            amountKey = 1
        }else{
            let distanceMeters = CLLocation(latitude: amountLatitude!, longitude: amountLongitude!).distance(from: location!)
            distanceAmount += Int(distanceMeters)
            
            if(speed < Int(distanceMeters)){
                speed = Int(distanceMeters)
            }
            
            amountLatitude = location?.coordinate.latitude
            amountLongitude = location?.coordinate.longitude
            
        }
        
    }//STARTKEY END
        
        if(speed > -1 && speed < 14){
            speed_guage.image = UIImage(named:"play_asset_gauge_4")!
            pointAmount += 15
        }else if(speed > 14 && speed < 29){
            speed_guage.image = UIImage(named:"play_asset_gauge_3")!
            pointAmount += 15
        }else if(speed > 29 && speed < 44){
            speed_guage.image = UIImage(named:"play_asset_gauge_2")!
            pointAmount += 15
        }else if(speed > 44){
            speed_guage.image = UIImage(named:"play_asset_gauge_1")!
            status_view.text = "시속보너스 1+"
            pointAmount += 15
            secondRemaining += 1
            bonusTime += 1
        }
        
    }
    
    func makeCircle(latitude : Double, longitude : Double){
        
        repeatCount += 1
        
        if(repeatCount%3 == 0){
            pointAmount += 250
            secondRemaining += 70
            status_view.text = "오차보너스 10+"
            bonusTime += 10
        }else if(repeatCount > 1){
            pointAmount += 40
            status_view.text = "보너스 없음"
            secondRemaining += 60
        }
        
        let circleCenter : CLLocationCoordinate2D  = CLLocationCoordinate2DMake((latitude), (longitude));
        circle = GMSCircle(position: circleCenter, radius: 0.062 * 1609.34)
        circle?.fillColor = UIColor(red: 255/255, green: 54/255, blue: 54/255, alpha: 0.5)
        circle?.strokeColor = UIColor(red: 255/255, green: 153/255, blue: 51/255, alpha: 0.5)
        circle?.strokeWidth = 2.5;
        circle?.map = self.mapView;
        
    }
    
    func removeCircle(){
       circle?.map = nil
    }
    
    final func killTimer(){
        self.timer?.invalidate()
        self.timer = nil
    }
    
    final private func startTimer() {
        
        // make it re-entrant:
        // if timer is running, kill it and start from scratch
        self.killInitialTimer()
        let fire = Date().addingTimeInterval(1)
        let deltaT : TimeInterval = 1.0
        
        self.timer = Timer(fire: fire, interval: deltaT, repeats: true, block: { (t: Timer) in
            
            if(self.secondRemaining == 0){
                
                self.killTimer()
                
                
                let preferences = UserDefaults.standard
                
                if(preferences.string(forKey: "repeat") != nil){
                    preferences.removeObject(forKey: "repeat")
                    preferences.removeObject(forKey: "pointAmount")
                    preferences.removeObject(forKey: "time")
                    preferences.removeObject(forKey: "distance")
                    preferences.removeObject(forKey: "bonus")
                    preferences.removeObject(forKey: "speed")
                }
                
                preferences.set(self.repeatCount, forKey: "repeat")
                preferences.set(self.pointAmount, forKey: "pointAmount")
                preferences.set(self.runTime, forKey: "time")
                preferences.set(self.distanceAmount, forKey: "distance")
                preferences.set(self.bonusTime, forKey: "bonus")
                preferences.set(self.speed, forKey: "speed")
                preferences.synchronize()
                
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "PlayResult", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "PlayResultController")
                self.present(newViewController, animated: true, completion: nil)
                
            }else{
                
                DispatchQueue.main.async() {
                    
                    self.count_view.text = ("\(self.secondRemaining)")
                }
                self.secondRemaining -= 1
                
            }
            
        })
        
        RunLoop.main.add(self.timer!, forMode: RunLoopMode.commonModes)
        
    }
    
    final func killInitialTimer(){
        self.initTimer?.invalidate()
        self.initTimer = nil
    }
    
    final private func startInitialTimer() {
        
        var count = 10
        
        // make it re-entrant:
        // if timer is running, kill it and start from scratch
        self.killInitialTimer()
        let fire = Date().addingTimeInterval(1)
        let deltaT : TimeInterval = 1.0
        
        self.initTimer = Timer(fire: fire, interval: deltaT, repeats: true, block: { (t: Timer) in
            
            if(count == 0){
                
                self.killInitialTimer()
                
                DispatchQueue.main.async() {
                    
                    self.initial_count_root_view.isHidden = true
                    self.view.bringSubview(toFront: self.count_root_view)
                    self.view.bringSubview(toFront: self.repeat_root_view)
                    self.view.bringSubview(toFront: self.status_root_view)
                    self.view.bringSubview(toFront: self.speed_root_view)
                    self.view.bringSubview(toFront: self.speed_guage_root_view)
                    self.view.bringSubview(toFront: self.stop_root_view)
                    
                    self.startKey = 1
                    self.repeatCount = 0
                    self.secondRemaining = 10
                    self.startTimer()
                    
                }
                
            }else{
                
                DispatchQueue.main.async() {
                    
                    self.initial_count_view.text = "\(count)"
                }
                count -= 1
                
            }
            
        })
        
        RunLoop.main.add(self.initTimer!, forMode: RunLoopMode.commonModes)
        
    }
    
}
