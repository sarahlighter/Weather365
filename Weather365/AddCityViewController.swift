//
//  AddCityViewController.swift
//  Weather365
//
//  Created by Ashish Ashish on 3/17/20.
//  Copyright © 2020 Ashish Ashish. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftSpinner
import SwiftyJSON
import RealmSwift

class AddCityViewController: UIViewController  {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tblView: UITableView!
    
    var arr = [LocationModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.delegate = self
        tblView.dataSource = self
        searchBar.delegate = self
        //print(Realm.Configuration.defaultConfiguration.fileURL)
    }
}


//MARK: Table view handlers

extension AddCityViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(arr[indexPath.row].cityName), \(arr[indexPath.row].stateName), \(arr[indexPath.row].countryName)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addCityToDB(for: indexPath.row)
    }
    
    func addCityToDB(for row: Int){
        let city = arr[row].cityName
        let alert = UIAlertController(title: "Add City", message: "Get weather for \(city)", preferredStyle:.alert)
        
        let OK = UIAlertAction(title: "OK", style: .default) { action in
            print(row)
            self.addCity(for: row)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
            print("cancel")
        }
        alert.addAction(OK)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func addCity(for index: Int){
        
        // check if city is already added
        if isCityAlreadyAdded(for: index){
            arr.removeAll()
            tblView.reloadData()
            return
        }
        
        // add city in DB
        let loc = arr[index]
        do {
            let realm = try Realm()
            try realm.write{
                realm.add(loc, update: Realm.UpdatePolicy.all)
            }
        }catch{
            print("Unable to add city in the database")
        }
        
        // clear table and searchbar and reload data
        arr.removeAll()
        searchBar.text = ""
        tblView.reloadData()
        
    }
    
    func isCityAlreadyAdded(for index: Int) -> Bool{
        
        let loc = arr[index]
        
        let realm = try! Realm()
        if realm.object(ofType: LocationModel.self, forPrimaryKey: loc.locationKey) != nil {
            return true
        }
        return false
    }
    
}

//MARK:- Search Bar functionality
extension AddCityViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // if search text is less than 3 dont do anything
        guard searchBar.text!.count > 3 else {
            // if empty delete everything
            if searchBar.text!.isEmpty {
                arr.removeAll()
                tblView.reloadData()
            }
            return;
        }
        
        // get values for the search string
        getAutocomplete(for: searchBar.text!)
    }
    
    func getAutocompleteURL(_ cityStr: String) -> String{
        
        return "\(Constants.autocompleteURL)?q=\(cityStr)&apikey=\(Constants.apiKey)"
    }
    
    func getAutocomplete(for cityStr: String){
        
        // get url
        let autCompleteURL = getAutocompleteURL(cityStr)
        
        // call API and get data
        Alamofire.request(autCompleteURL).responseJSON { response in
            
            if response.error != nil {
                print("Error in getting Autocomplete Error: \(response.error?.localizedDescription)")
                return
            }
            print(response.result.value!)
            let autoCompleteJSON : [JSON] = JSON(response.result.value!).arrayValue
            //print(autoCompleteJSON)
            
            self.arr.removeAll()
            for city in autoCompleteJSON {
                let citydata = LocationModel()
                citydata.locationKey = city["Key"].stringValue
                citydata.cityName    = city["LocalizedName"].stringValue
                citydata.countryName = city["Country"]["LocalizedName"].stringValue
                citydata.stateName   = city["AdministrativeArea"]["ID"].stringValue
                self.arr.append(citydata)
                print(city)
            }
            self.tblView.reloadData()
            
        }// end of request
    }// end of function
}
