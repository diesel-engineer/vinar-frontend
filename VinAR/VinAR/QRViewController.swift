//
//  QRViewController.swift
//  VinAR
//
//  Created by Kha Nguyễn on 9/6/19.
//  Copyright © 2019 VinAR. All rights reserved.
//

import UIKit
import SafariServices
import AVFoundation

class QRViewController: UIViewController {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    lazy var overlayView: QROverlayView = QROverlayView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(overlayView)
        overlayView.snp.makeConstraints { $0.edges.equalToSuperview() }
        overlayView.alpha = 0
        UIView.animate(withDuration: 0.2, animations: { self.overlayView.alpha = 1 })

        // QR Scanner
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func found(code: String) {
        //if code.contains("vectary") {
            let urlString = code
            
            let arWebVC = ARViewController()
            arWebVC.urlString = urlString
            present(arWebVC, animated: true)

//            if let url = URL(string: urlString) {
//                let sfConfiguration = SFSafariViewController.Configuration()
//                sfConfiguration.barCollapsingEnabled = true
//                sfConfiguration.entersReaderIfAvailable = false
//                let arWebVC = ARViewController(url: url, configuration: sfConfiguration)
//                
//                arWebVC.delegate = self
//                present(arWebVC, animated: true)
            
                //
                //                arWebVC.delegate = self
                //                present(arWebVC, animated: true)
//            }
        //}
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

extension QRViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
}

extension QRViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }
}
