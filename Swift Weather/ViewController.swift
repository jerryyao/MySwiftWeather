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
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var loadingIndicator:UIActivityIndicatorView!
    @IBOutlet weak var loading: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.loadingIndicator.startAnimating()
  
        let background = UIImage(named: "background.png")
        self.view.backgroundColor = UIColor(patternImage: background!)
        
        if (ios8()) {
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.startUpdatingLocation()
    }

    func ios8() -> Bool {
        return UIDevice.currentDevice().systemVersion == "8.3"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location:CLLocation = locations[locations.count - 1] as! CLLocation
        if (location.horizontalAccuracy > 0) {
            println(location.coordinate.latitude)
            println(location.coordinate.longitude)
            self.updateWeatherInfo(location.coordinate.latitude, longitude: location.coordinate.longitude)
            locationManager.stopUpdatingLocation()
        }
    }
    func updateWeatherInfo(latitude:CLLocationDegrees, longitude:CLLocationDegrees) {
        let manager = AFHTTPRequestOperationManager()
        let url = "http://api.openweathermap.org/data/2.5/weather/"
        let params = ["lat":latitude, "lon":longitude, "cnt":0]
        println(params)
        
        manager.GET(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                println("JSON: " + responseObject.description!)
                self.updateUISuccess(responseObject as! NSDictionary!)
            },
            failure: { (operation: AFHTTPRequestOperation!,
                error: NSError!) in
                println("Error: " + error.localizedDescription)
        })
    }
    func updateUISuccess(jsonResult:NSDictionary!) {
        
        self.loadingIndicator.stopAnimating()
        self.loading.text = nil
        self.loadingIndicator.hidden = true
        
        if let tempResult = ((jsonResult["main"] as! NSDictionary)["temp"] as? Double) {
            
            // If we can get the temperature from JSON correctly, we assume the rest of JSON is correct.
            var temperature: Double
            if let sys = (jsonResult["sys"] as? NSDictionary) {
                if let country = (sys["country"] as? String) {
                    if (country == "US") {
                        // Convert temperature to Fahrenheit if user is within the US
                        temperature = round(((tempResult - 273.15) * 1.8) + 32)
                    }
                    else {
                        // Otherwise, convert temperature to Celsius
                        temperature = round(tempResult - 273.15)
                    }
                    
                    // Is it a bug of Xcode 6? can not set the font size in IB.
                    self.temperature.font = UIFont.boldSystemFontOfSize(60)
                    self.temperature.text = "\(temperature)°"
                }
                
                if let name = jsonResult["name"] as? String {
                    self.location.font = UIFont.boldSystemFontOfSize(25)
                    self.location.text = name
                }
                
                if let weather = jsonResult["weather"] as? NSArray {
                    var condition = (weather[0] as! NSDictionary)["id"] as! Int
                    var sunrise = sys["sunrise"] as! Double
                    var sunset = sys["sunset"] as! Double
                    
                    var nightTime = false
                    var now = NSDate().timeIntervalSince1970
                    // println(nowAsLong)
                    
                    if (now < sunrise || now > sunset) {
                        nightTime = true
                    }
                    self.updateWeatherIcon(condition, nightTime: nightTime)
                    return
                }
            }
        }
        else {
            self.loading.text = "天气信息不可用"
        }
        
    }
    
    // Converts a Weather Condition into one of our icons.
    // Refer to: http://bugs.openweathermap.org/projects/api/wiki/Weather_Condition_Codes
    func updateWeatherIcon(condition: Int, nightTime: Bool) {
        // Thunderstorm
        if (condition < 300) {
            if nightTime {
                self.icon.image = UIImage(named: "tstorm1_night")
            } else {
                self.icon.image = UIImage(named: "tstorm1")
            }
        }
            // Drizzle
        else if (condition < 500) {
            self.icon.image = UIImage(named: "light_rain")
        }
            // Rain / Freezing rain / Shower rain
        else if (condition < 600) {
            self.icon.image = UIImage(named: "shower3")
        }
            // Snow
        else if (condition < 700) {
            self.icon.image = UIImage(named: "snow4")
        }
            // Fog / Mist / Haze / etc.
        else if (condition < 771) {
            if nightTime {
                self.icon.image = UIImage(named: "fog_night")
            } else {
                self.icon.image = UIImage(named: "fog")
            }
        }
            // Tornado / Squalls
        else if (condition < 800) {
            self.icon.image = UIImage(named: "tstorm3")
        }
            // Sky is clear
        else if (condition == 800) {
            if (nightTime){
                self.icon.image = UIImage(named: "sunny_night") // sunny night?
            }
            else {
                self.icon.image = UIImage(named: "sunny")
            }
        }
            // few / scattered / broken clouds
        else if (condition < 804) {
            if (nightTime){
                self.icon.image = UIImage(named: "cloudy2_night")
            }
            else{
                self.icon.image = UIImage(named: "cloudy2")
            }
        }
            // overcast clouds
        else if (condition == 804) {
            self.icon.image = UIImage(named: "overcast")
        }
            // Extreme
        else if ((condition >= 900 && condition < 903) || (condition > 904 && condition < 1000)) {
            self.icon.image = UIImage(named: "tstorm3")
        }
            // Cold
        else if (condition == 903) {
            self.icon.image = UIImage(named: "snow5")
        }
            // Hot
        else if (condition == 904) {
            self.icon.image = UIImage(named: "sunny")
        }
            // Weather condition is not available
        else {
            self.icon.image = UIImage(named: "dunno")
        }
    }
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
        self.loading.text = "地理位置信息不可用"
    }


}

