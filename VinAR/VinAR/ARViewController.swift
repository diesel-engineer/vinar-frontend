//
//  ARViewController.swift
//  VinAR
//
//  Created by Kha Nguyễn on 9/6/19.
//  Copyright © 2019 VinAR. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import SafariServices

class ARViewController: UIViewController, WKUIDelegate {
    
    public var urlString: String? = nil
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "callback")
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = contentController

        webView = WKWebView(frame: CGRect(x: 0, y: 90, width: view.frame.size.width, height: view.frame.size.height - 50), configuration: webConfiguration)
        webView.uiDelegate = self
        view.addSubview(webView)
        
        if let urlString = self.urlString {
//            let myURL = URL(string: urlString)
            let myURL = Bundle.main.url(forResource: "page", withExtension: "html")

            let myRequest = URLRequest(url: myURL!)
            webView.load(myRequest)
        }
        
        let closeButton = UIButton(frame: CGRect(x: 5, y: 50, width: 60, height: 20))
        closeButton.setTitle("Back", for: .normal)
        closeButton.setTitleColor(.blue, for: .normal)
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(onBackTap(_:)), for: .touchUpInside)
    }
    
    @IBAction func onBackTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension ARViewController: WKScriptMessageHandler, WKNavigationDelegate {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        //This function handles the events coming from javascript. We'll configure the javascript side of this later.
        //We can access properties through the message body, like this:
        
        if message.name == "callback" {
            guard let response = message.body as? [String: AnyObject] else { return }
            let param1 = response["param1"] as? String
            let param2 = response["param2"] as? String
            
            if let param1 = param1, let param2 = param2, param1.contains("view_ar") {
                let sfConfiguration = SFSafariViewController.Configuration()
                sfConfiguration.barCollapsingEnabled = true
                sfConfiguration.entersReaderIfAvailable = false
                if let url = URL(string: param2) {
                    let sfSafariVC = SFSafariViewController(url: url, configuration: sfConfiguration)
                    present(sfSafariVC, animated: true)
                }
            }
            
            if let param1 = param1, let param2 = param2, param1.contains("add_to_cart") {
                let paymentVC = CartViewController(nibName: "CartViewController", bundle: nil)
                self.present(paymentVC, animated: true, completion: nil)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //This function is called when the webview finishes navigating to the webpage.
        //We use this to send data to the webview when it's loaded.
    }
}
