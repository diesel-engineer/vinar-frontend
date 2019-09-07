//
//  CartTableViewCell.swift
//  VinIDDemo
//
//  Created by Xuân Quỳnh Lê on 9/6/19.
//  Copyright © 2019 Vinid. All rights reserved.
//

import UIKit

class CartTableViewCell: UITableViewCell {
    @IBOutlet weak var addItemView: AddItemView!
    var closeTouched:(()->Void)?
    var decreaseTouched:((Int)->Void)?
    var increaseTouched:((Int)->Void)?
    
    @IBOutlet weak var productImg: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var price: UILabel!
    
    func setData(product: ProductVO) {
        productName.text = product.productName
        price.text = String(Int(product.price)) + " Đ"
        addItemView.setNum(num: String(product.amount))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addItemView.decreaseTouched = {[unowned self] num in
            self.decreaseTouched?(num)
        }
        addItemView.increaseTouched = {[unowned self] num in
            self.increaseTouched?(num)
        }
    }

    @IBAction func onCloseTouched(_ sender: Any) {
        closeTouched?()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
    
}
