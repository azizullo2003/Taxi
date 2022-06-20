//
//  GraphopperResponse.swift
//  UZTAXI
//
//  Created by Muhammad Azizullo on 18/05/22.
//

import Foundation

struct GraphopperResponse: Decodable {
    var paths: [Points]
}

struct Points: Decodable {
    var distance : Float
    var points: String
    
}

