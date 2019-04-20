//
//  CardsDataSingleton.swift
//  deepPoker
//
//  Created by Waddah Al Drobi on 2019-04-20.
//  Copyright © 2019 Waddah Al Drobi. All rights reserved.
//

import Foundation

class CardsDataSingleton {
    
    static let shared = CardsDataSingleton()
    var data: Dictionary<String, [String]>
    
    private init() {
        data = Dictionary<String, [String]> ()

    }
    
    
    
}
