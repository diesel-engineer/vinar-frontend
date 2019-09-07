//
//  ViewController.swift
//  VinAR
//
//  Created by Kha Nguyễn on 9/6/19.
//  Copyright © 2019 VinAR. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imgBackground: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            imgBackground.image = UIImage(named: "ipad_bgr")
        } else {
            imgBackground.image = UIImage(named: "iphone_bgr")
        }
        
    }

    @IBAction func openQRScanner(_ sender: Any) {
        
    }
    
}

