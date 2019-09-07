//
//  VOScannerOverlayView.swift
//  VOScannerUI
//
//  Created by Anh Tran on 5/10/19.
//  Copyright © 2019 vinid. All rights reserved.
//

import UIKit
import SnapKit

class QROverlayView: UIView {
    
    private lazy var focusImageView = UIImageView()
    private lazy var overlayView = UIView()
    
    public lazy var flashButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ic-scanner-flash-off"), for: .normal)
        button.contentMode = .center
        button.sizeToFit()
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.backgroundColor = button.isHighlighted ? UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.53333336) : UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.23921569)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        configureView()
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        configureView()
        layout()
    }
    
    private func setupView() {
        addSubview(overlayView)
        addSubview(focusImageView)
        addSubview(flashButton)
    }
    
    private func configureView() {
        backgroundColor = .clear
        let insets = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        let image = UIImage(named: "ic-scanner-focus")!.resizableImage(withCapInsets: insets)
        focusImageView.image = image
        setTitle(false)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        updateBlurViewHole()
    }
    
    func setTitle(_ isChange: Bool) {
        if isChange {
            setBlinkFlashButton()
        } else {
            self.flashButton.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.23921569)
        }
    }
    func setBlinkFlashButton() {
        self.flashButton.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.23921569)
        UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseOut, .repeat, .autoreverse, .allowUserInteraction], animations: {
            self.flashButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        })
    }
    
    private func updateBlurViewHole() {
        let maskView = UIView(frame: overlayView.bounds)
        maskView.clipsToBounds = true
        maskView.backgroundColor = UIColor.clear
        
        let outerPath = UIBezierPath(roundedRect: overlayView.bounds, cornerRadius: 0)
        let innerPath = UIBezierPath(roundedRect: focusImageView.frame, cornerRadius: 0)
        outerPath.append(innerPath)
        outerPath.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.fillRule = .evenOdd
        fillLayer.path = outerPath.cgPath
        
        maskView.layer.addSublayer(fillLayer)
        
        overlayView.mask = maskView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateBlurViewHole()
    }
    
    private func layout() {
        focusImageView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).multipliedBy(0.6875)
            make.size.equalTo(self.snp.height).multipliedBy(0.375)
        }
        overlayView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalTo(self)
        }
        flashButton.snp.makeConstraints { make in
            make.height.width.equalTo(48)
            make.centerX.equalTo(self)
            make.top.equalTo(focusImageView.snp.bottom).offset(20)
        }
    }
    
    var focusFrame: CGRect {
        // Top-half screen
        let topHalfFrame = CGRect(x: frame.origin.x,
                                  y: frame.origin.y,
                                  width: frame.size.width,
                                  height: frame.size.height / 2.0)
        return topHalfFrame.union(focusImageView.frame)
    }
}
