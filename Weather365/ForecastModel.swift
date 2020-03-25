//
//  ExtendedForecastModel.swift
//  Weather365
//
//  Created by Ashish Ashish on 3/24/20.
//  Copyright © 2020 Ashish Ashish. All rights reserved.
//

import Foundation

class ForecastModel{
    
    var date  = ""
    var minTemp = ""
    var maxTemp = ""
    var dayCondition = ""
    var nightCondition = ""
    
    init(_ date: String,
         _ minTemp: String,
         _ maxTemp: String,
         _ dayCondition: String,
         _ nightCondition: String
         )
    {
        self.date = date
        self.minTemp = minTemp
        self.maxTemp = maxTemp
        self.dayCondition = dayCondition
        self.nightCondition = nightCondition
    }
//    EpochDate
//        currentJSON[0]["Temperature"]["Minimum"]["Value"]
//        currentJSON[0]["Temperature"]["Maximum"]["Value"]
//        currentJSON[0]["Day"]["IconPhrase"]
//        currentJSON[0]["Day"]["IconPhrase"]
    
    
    
}
