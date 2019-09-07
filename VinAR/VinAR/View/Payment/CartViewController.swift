//
//  CartViewController.swift
//  VinIDDemo
//
//  Created by Xuân Quỳnh Lê on 9/6/19.
//  Copyright © 2019 Vinid. All rights reserved.
//

import UIKit

class CartViewController: UIViewController {
    @IBOutlet weak var itemTableView: UITableView!
    @IBOutlet weak var sumItem: UILabel!
    @IBOutlet weak var feeShip: UILabel!
    @IBOutlet weak var sumTotal: UILabel!
    var productList : ProductListVO?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        updateSum()
        loadLocalData()
    }
    
    private func loadLocalData() {
        if let path = Bundle.main.path(forResource: "product", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [[String: AnyObject]] {
                    productList = ProductListVO.init(items: jsonResult)
                    updateSum()
                    itemTableView.reloadData()
                }
            } catch {
                // handle error
                print("load error")
            }
        }
    }
    
    private func updateSum() {
        var sum : Double = 0
        
        if productList == nil {
            sumItem.text =  "0 Đ"
            sumTotal.text = "0 Đ"
            return
        }
        for product in productList!.list {
            sum = sum + product.price * Double(product.amount)
        }
        
        sumItem.text = String(Int(sum)) + " Đ"
        sumTotal.text = String(Int(sum)) + " Đ"
    }
    
    @IBAction func onCloseTouched(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupUI() {
        itemTableView.register(UINib(nibName: "CartTableViewCell", bundle: nil), forCellReuseIdentifier: "CartTableViewCell")
    }

    @IBAction func onPaymentTouched(_ sender: Any) {
        print("payment touched")
        if productList != nil && productList!.list.count > 0 {
            //Open success payment screen
            let paySuccessVC = PaymentSuccessViewController(nibName: "PaymentSuccessViewController", bundle: nil)
            self.present(paySuccessVC, animated: true, completion: nil)
        }
    }
    
}

extension CartViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if productList != nil {
            return productList!.list.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartTableViewCell") as! CartTableViewCell
        cell.setData(product: productList!.list[indexPath.row])
        
        cell.decreaseTouched = {[unowned self] num in
            print("decreaseTouched")
            self.productList!.list[indexPath.row].amount = num
            self.updateSum()
        }
        cell.increaseTouched = {[unowned self] num in
            print("increaseTouched")
            self.productList!.list[indexPath.row].amount = num
            self.updateSum()
        }
        
        cell.closeTouched = {[unowned self]  in
         //delete cell
            self.productList!.list.remove(at: indexPath.row)
            self.updateSum()
            self.itemTableView.reloadData()
        }
        return cell
    }
    
    
}
