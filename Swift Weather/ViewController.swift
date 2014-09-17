//
//  ViewController.swift
//  Swift Weather
//
//  Created by 姚嘉 on 14-9-17.
//  Copyright (c) 2014年 yaojia. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager:CLLocationManager = CLLocationManager()
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
  
        
        if (ios8()) {
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.startUpdatingLocation()
    }

    func ios8() -> Bool {
        return UIDevice.currentDevice().systemVersion == "8.0"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location:CLLocation = locations[locations.count - 1] as CLLocation
        if (location.horizontalAccuracy > 0) {
            println(location.coordinate.latitude)
            println(location.coordinate.longitude)
            
            locationManager.stopUpdatingLocation()
        }
    }
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
    }


}

