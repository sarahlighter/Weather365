//
//  AllCitiesTableViewController.swift
//  Weather365
//
//  Created by Ashish Ashish on 3/24/20.
//  Copyright © 2020 Ashish Ashish. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner
import SwiftyJSON
import PromiseKit
import RealmSwift

class AllCitiesTableViewController: UITableViewController {

    let arr = ["Ashish","Tom","Peter"]
    
    var currentArr = [CurrentWeather]()
    
    @IBOutlet var tblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initValues()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currentArr.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let i = indexPath.row
        cell.textLabel?.text = "\(currentArr[i].city), \(currentArr[i].condition), \(currentArr[i].temp) ℉"

        return cell
    }
    
    
    func initValues(){
        
        getUpdatedWeather().done { results in
            self.currentArr.append(contentsOf: results)
            
            self.tblView.reloadData()
        }
        .catch { error in
            print(error.localizedDescription)
        }
        
        
    }
    
    //    //.done { (temp, condition) in
    //
    //        self.lblCurrentCondition.text = condition
    //        self.lblTemperature.text = "\(temp)℉"
    //
    //    }.catch { (error) in
    //        print(error)
    //    }
    
    
    
    func getUpdatedWeather() -> Promise<[CurrentWeather]>{
        
        let locations = getLocations()
        
        let locationURLS = getCurrentWeatherURLS(locations)
        
        var promises : [Promise<CurrentWeather>] = []
        
        for i in 0 ... locations.count-1 {
            
            promises.append(getCurrentConditions(for: locationURLS[i], locations[i].locationKey, locations[i].cityName) )
        }
        
        
        return when(fulfilled: promises)
        
        
    }
    
    
    func getLocations() -> [LocationModel]{
        var arrLocations = [LocationModel]()
        do{
            let realm = try! Realm()
            let locations = realm.objects(LocationModel.self)
            
            for location in locations {
                arrLocations.append(location)
            }
        
            
        }catch{
            print("Error in reading from DB")
            
        }
        return arrLocations
        
    }
    
    func getCurrentWeatherURLS(_ locations: [LocationModel]) -> [String]{
        var arrURLS = [String]()
        for location in locations{
            arrURLS.append("\(Constants.currentWeatherURL)\(location.locationKey)?apikey=\(Constants.apiKey)")
        }
        
        return arrURLS
    }
    

    
    
    func getCurrentConditions(for URL: String, _ key : String, _ city: String) -> Promise<CurrentWeather>{
        
        return Promise<CurrentWeather> { seal -> Void  in
            
            Alamofire.request(URL).responseJSON { response in
                if response.error != nil {
                    seal.reject(response.error!)
                }
                
                let currentJSON : JSON = JSON(response.result.value!)
                
                if  currentJSON[0]["WeatherText"].exists() &&
                    currentJSON[0]["Temperature"]["Imperial"]["Value"].exists() {
                    
                    let condition = currentJSON[0]["WeatherText"].stringValue
                    let temp = currentJSON[0]["Temperature"]["Imperial"]["Value"].stringValue
                    let current = CurrentWeather(city,condition, temp, key)
                    
                    seal.fulfill(current)
                }
            }
        }// end of promise
    }// end of function
    
}
