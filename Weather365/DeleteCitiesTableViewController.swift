//
//  DeleteCitiesTableViewController.swift
//  Weather365
//
//  Created by Ashish Ashish on 3/24/20.
//  Copyright © 2020 Ashish Ashish. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner
import SwiftyJSON
import RealmSwift

class DeleteCitiesTableViewController: UITableViewController {

    var arr = [LocationModel]()
    @IBOutlet var tblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCities()

    }
    
    func loadCities(){
        
        do{
           let realm = try! Realm()
           let locations = realm.objects(LocationModel.self)
           
           for location in locations {
               arr.append(location)
           }
           tblView.reloadData()
           
       }catch{
           print("Error in reading from DB")
       }
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arr.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = "\(arr[indexPath.row].cityName), \(arr[indexPath.row].stateName), \(arr[indexPath.row].countryName)"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
           let loc = arr[indexPath.row]
           self.deleteCity(for: loc)
           self.arr.remove(at: indexPath.row)
           tblView.deleteRows(at: [indexPath], with: .fade)
       }
    }
    
    func deleteCity(for location: LocationModel){
        let realm = try! Realm()
        try! realm.write{
            realm.delete(location)
        }
    }
    

}
