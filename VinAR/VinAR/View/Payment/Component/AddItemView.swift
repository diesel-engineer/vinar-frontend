//
//  AddItemView.swift
//  VinIDDemo
//
//  Created by Xuân Quỳnh Lê on 9/6/19.
//  Copyright © 2019 Vinid. All rights reserved.
//

import UIKit

extension UIView {
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
class AddItemView: UIView {
    let kCONTENT_XIB_NAME = "AddItemView"
    var decreaseTouched:((Int)->Void)?
    var increaseTouched:((Int)->Void)?
    
    @IBOutlet weak var txtNumber: UILabel!
    
    func setNum(num: String) {
        txtNumber.text = num
    }
    
    @IBAction func onDecreaseTouched(_ sender: Any) {
        guard var num = Int(txtNumber.text!) else {
            return
        }
        
        if num == 0 {
            return
        }
        num = num - 1
        txtNumber.text = String(num)
        decreaseTouched?(num)
    }
    
    @IBAction func onIncreaseTouched(_ sender: Any) {
        guard var num = Int(txtNumber.text!) else {
            return
        }
        
        if num >= 100 {
            return
        }
        num = num + 1
        txtNumber.text = String(num)
        increaseTouched?(num)
    }
    
    @IBOutlet var contentView: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
    }
    
}
