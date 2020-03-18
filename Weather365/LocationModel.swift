//
//  LocationModel.swift
//  Weather365
//
//  Created by Ashish Ashish on 3/17/20.
//  Copyright © 2020 Ashish Ashish. All rights reserved.
//

import Foundation
import RealmSwift

class LocationModel: Object {
    @objc dynamic var locationKey: String = ""
    @objc dynamic var cityName: String = ""
    @objc dynamic var countryName: String = ""
    @objc dynamic var stateName: String = ""
    
    override static func primaryKey() -> String? {
        return "locationKey"
    }
    
    
}
