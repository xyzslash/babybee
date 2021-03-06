//
//  CGContentModel.swift
//  BabyBee
//
//  Created by Hawk on 14/09/16.
//  Copyright © 2016 v.vasilenko. All rights reserved.
//

import Foundation
import ObjectMapper

class CGContentModel : NSObject, Mappable {
    var name : String!
    var contentUrl : String!
    var payment : Bool!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        contentUrl <- map["content"]
        payment <- map["payment"]
    }
}
