//
//  File.swift
//  
//
//  Created by Turner Eison on 1/13/22.
//

import Foundation
import Vapor

struct ActuallyGroup: Encodable {
    let sortedList: [Actually]
    let total: Int
    let average: Int
    let amountPerDay: [AmountPerDayData]
    
    struct AmountPerDayData: Encodable {
        let classNumber: Int
        let amount: Int
        let averageSecondsBetween: Int
    }
}
