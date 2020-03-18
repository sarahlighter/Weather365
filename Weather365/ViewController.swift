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
import RealmSwift


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // ashishsingh@gmail.com
    
    @IBOutlet weak var lblCityName: UILabel!
    
    @IBOutlet weak var lblCurrentCondition: UILabel!
    
    @IBOutlet weak var lblTemperature: UILabel!
    
    @IBOutlet weak var tblView: UITableView!
    
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    
    var arr = [LocationModel]()
    
    
    
    let locationManager = CLLocationManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        tblView.delegate = self
        tblView.dataSource = self
        pickerView.delegate = self
        pickerView.dataSource = self
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadCities();
    }
    
    
    func loadCities(){
        
        arr.removeAll()
        let dummyLoc = LocationModel()
        dummyLoc.locationKey = "-1"
        dummyLoc.cityName    = "Seattle"
        dummyLoc.countryName = "US"
        dummyLoc.stateName = "WA"
        arr.append(dummyLoc)
        
        do{
            let realm = try! Realm()
            let locations = realm.objects(LocationModel.self)
            
            for location in locations {
                arr.append(location)
            }
            tblView.reloadData()
            pickerView.reloadAllComponents()
            
            
        }catch{
            print("Error in reading from DB")
            
        }
        
        
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
                self.updateCurrentTempAndCondition(locKey)
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

extension ViewController: UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.row == 0 {
            cell.textLabel?.text = "Current Location"
        }else{
            cell.textLabel?.text = "\(arr[indexPath.row].cityName), \(arr[indexPath.row].stateName)"
        }
        
        
        return cell
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arr.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0{
            return "Current Location"
        }
        return "\(arr[row].cityName), \(arr[row].stateName)"
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if row == 0 {
            print("current location selected")
        }
        else{
            // set the city name
            self.lblCityName.text = "\(arr[row].cityName), \(arr[row].stateName)"
            
            let locKey = arr[row].locationKey
            updateCurrentTempAndCondition(locKey)
        }
    }
    
    
    func updateCurrentTempAndCondition(_ locKey: String){
        
        // get values for current condition and temp
        let currentURL = self.getCurrentWeatherURL(locKey)
        self.getCurrentConditions(for: currentURL)
        .done { (temp, condition) in
            
            self.lblCurrentCondition.text = condition
            self.lblTemperature.text = "\(temp)℉"
            
        }.catch { (error) in
            print(error)
        }
        
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
    
    func getextendedForecast(_ locationKey: String){
        
    }
}
