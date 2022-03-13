//
//  File.swift
//  
//
//  Created by Turner Eison on 2/2/22.
//

import Foundation
import Vapor

struct QuickData: Content {
    // Manually increment this on unknown days
    static let numberOfUnknownDays = 2
    let total: Int
    let today: Int
    
    init(total: Int, today: Int) {
        self.total = total - Self.numberOfUnknownDays * 999
        self.today = today
    }
}
