//
//  ProductVO.swift
//  VinAR
//
//  Created by Xuân Quỳnh Lê on 9/7/19.
//  Copyright © 2019 VinAR. All rights reserved.
//

import Foundation

class ProductVO {
    var productName: String
    var productImage: String
    var price: Double
    var amount: Int
    init(item: [String: AnyObject]) {
        productName = item["productName"] as? String ?? ""
        productImage = ""
        price = item["price"] as? Double ?? 0
        amount = item["amount"] as? Int ?? 0
    }
}

class ProductListVO {
    var list : [ProductVO]
    
    init(items: [[String: AnyObject]]) {
        list = []
        
        for item in items {
            list.append(ProductVO.init(item: item))
        }
    }
}
