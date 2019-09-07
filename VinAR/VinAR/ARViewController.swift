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
import QuickLook

class ARViewController: UIViewController, WKUIDelegate, QLPreviewControllerDataSource {
    
    public var urlString: String? = nil
    public var arModelString: String? = nil
    
    var webView: WKWebView!
    var showARFirstTime: Bool = true
    
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
            let myURL = URL(string: urlString)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if showARFirstTime {
            showARFirstTime = false
            if let arModelString = self.arModelString {
                if let url = URL(string: arModelString) {
                    showARViewer(itemURL: url)
                }
            }
        }
    }
    
    var fileURL: URL?

    func showARViewer(itemURL: URL) {
        
        let quickLookController = QLPreviewController()
        quickLookController.dataSource = self
        
        do {
            self.downloadFile(itemURL: itemURL) { [unowned self] success, destURL in
                if success {
                    self.fileURL = destURL
                    if QLPreviewController.canPreview(self.fileURL! as QLPreviewItem) {
                        quickLookController.currentPreviewItemIndex = 0
                        self.present(quickLookController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileURL! as QLPreviewItem
    }
    
    func downloadFile(itemURL: URL?, completion: @escaping (_ success: Bool, _ fileLocation: URL?) -> Void) {
        guard let itemURL = itemURL else {
            completion(false, nil)
            return
        }
        
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destDir = docDir.appendingPathComponent("ar.usdz")
        
        if FileManager.default.fileExists(atPath: destDir.path) {
            completion(true, destDir)
        } else {
            URLSession.shared.downloadTask(with: itemURL, completionHandler: { (location, response, error) -> Void in
                guard let tempLocation = location, error == nil else { return }
                do {
                    try FileManager.default.moveItem(at: tempLocation, to: destDir)
                    completion(true, destDir)
                } catch {
                    completion(false, nil)
                }
            }).resume()
        }
    }
}

extension ARViewController: WKScriptMessageHandler, WKNavigationDelegate {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "callback" {
            guard let response = message.body as? [String: AnyObject] else { return }
            let param1 = response["param1"] as? String
            let param2 = response["param2"] as? String
            
            if let param1 = param1, let param2 = param2, param1.contains("view_ar") {
                if let url = URL(string: param2) {
                    showARViewer(itemURL: url)
                }
            }
            
            if let param1 = param1, param1.contains("add_to_cart") {
                let paymentVC = CartViewController(nibName: "CartViewController", bundle: nil)
                self.present(paymentVC, animated: true, completion: nil)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {}
}
