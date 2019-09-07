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
import RxSwift
import RxCocoa

class QRViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    lazy var overlayView: QROverlayView = QROverlayView()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        view.addSubview(overlayView)
        overlayView.snp.makeConstraints { $0.edges.equalToSuperview() }
        overlayView.alpha = 0
        UIView.animate(withDuration: 0.2, animations: { self.overlayView.alpha = 1 })
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
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
        
        setupFlash()
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
        
        let productParam = getQueryStringParameter(url: urlString, param: "producturl")
        let modelParam = getQueryStringParameter(url: urlString, param: "modelurl")
        
        if let productParam = productParam, let modelParam = modelParam {
            let arWebVC = ARViewController()
            arWebVC.urlString = "https://makbiz.vn/\(productParam)"
            arWebVC.arModelString = "https://makbiz.vn/\(modelParam)"
            present(arWebVC, animated: true)
        } else {
            if (captureSession?.isRunning == false) {
                captureSession.startRunning()
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return true
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

private extension QRViewController {
    func setupFlash() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        overlayView.flashButton.isHidden = !device.hasTorch
        
        overlayView.flashButton.rx.tap.asObservable()
            .subscribe(onNext: { [unowned self] _ in
                self.toggleTorch()
                }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        overlayView.flashButton.rx.tap.asObservable()
            .flatMap { event in
                Observable.just(event).delaySubscription(0.1, scheduler: MainScheduler.instance)
            }
            .subscribe(onNext: { [unowned self] _ in
                self.refreshSession()
                }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
    
    func refreshSession() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        let icon = device.isTorchActive ? UIImage(named: "ic-scanner-flash-on") : UIImage(named: "ic-scanner-flash-off")
        overlayView.flashButton.setImage(icon, for: .normal)
    }
    
    func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        guard device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            switch device.torchMode {
            case .on:
                device.torchMode = .off
            case .off:
                device.torchMode = .on
            default:
                break
            }
            device.unlockForConfiguration()
        } catch {
        }
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
}
