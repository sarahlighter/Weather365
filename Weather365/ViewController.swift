//
//  ViewController.swift
//  Weather365
//
//  Created by Ashish Ashish on 3/10/20.
//  Copyright © 2020 Ashish Ashish. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftSpinner
import SwiftyJSON
import PromiseKit


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // ashishsingh@gmail.com
    
    @IBOutlet weak var lblCityName: UILabel!
    
    @IBOutlet weak var lblCurrentCondition: UILabel!
    
    @IBOutlet weak var lblTemperature: UILabel!
    
    let locationManager = CLLocationManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func getlocationURL(_ latLng: String) -> String{
        
        return "\(Constants.locationURL)?q=\(latLng)&apikey=\(Constants.apiKey)"
    }
    
    func getCurrentWeatherURL(_ locationKey: String) -> String{
        
        return "\(Constants.currentWeatherURL)\(locationKey)?apikey=\(Constants.apiKey)"
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let currLocation = locations.last {
            
            let lat = currLocation.coordinate.latitude
            let lng = currLocation.coordinate.longitude
            
            let locationURL = getlocationURL("\(lat),\(lng)")
            
            
            getLocationKey(for: locationURL)
            .done { locKey, city in
                self.lblCityName.text = city
                let currentURL = self.getCurrentWeatherURL(locKey)
                self.getCurrentConditions(for: currentURL)
                .done { (temp, condition) in
                    
                    self.lblCurrentCondition.text = condition
                    self.lblTemperature.text = "\(temp)℉"
                    
                }.catch { (error) in
                    print(error)
                }
            }
            .catch { error in
                print(error)
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error in getting location \(error)")
    }
    
}

extension ViewController {
    
    func getLocationKey(for URL: String) -> Promise<(String, String)>{
        
        return Promise<(String, String)> { seal -> Void in
            Alamofire.request(URL).responseJSON { response in
                
                let locationJSON : JSON = JSON(response.result.value!)
                if  locationJSON["Key"].exists() &&
                    locationJSON["LocalizedName"].exists()
                    {
                        let locKey = locationJSON["Key"].stringValue
                        let city = locationJSON["LocalizedName"].stringValue
                        seal.fulfill( (locKey, city) )
                    }
                
                if response.error != nil{
                    seal.reject(response.error!)
                }
            }
        }// End of promise
    }// end of function getLocationKey
    
    func getCurrentConditions(for URL: String) -> Promise<(String, String)>{
        
        return Promise<(String, String)> { seal -> Void  in
            
                Alamofire.request(URL).responseJSON { response in
                    if response.error != nil {
                        seal.reject(response.error!)
                    }
                    
                    let currentJSON : JSON = JSON(response.result.value!)
                    
                    if  currentJSON[0]["WeatherText"].exists() &&
                        currentJSON[0]["Temperature"]["Imperial"]["Value"].exists() {
                        
                        let condition = currentJSON[0]["WeatherText"].stringValue
                        let temp = currentJSON[0]["Temperature"]["Imperial"]["Value"].stringValue
                        
                        seal.fulfill((temp, condition))
                    }
            }// end of promise
        }// end of function
    
    }
}
