//
//  UIView+.swift
//  Going-iOS
//
//  Created by 곽성준 on 12/23/23.
//

import UIKit

extension UIView {
    
    // UIView 여러 개 인자로 받아서 한 번에 addSubview
    func addSubviews(_ views: UIView...) {
        views.forEach { self.addSubview($0) }
    }
    
    //모서리둥글게
    func roundCorners(cornerRadius: CGFloat, maskedCorners: CACornerMask) {
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = CACornerMask(arrayLiteral: maskedCorners)
    }
    
    enum GradientAxis {
        case vertical
        case horizontal
    }
    
    func setGradient(firstColor: UIColor, secondColor: UIColor, axis: GradientAxis) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [firstColor.cgColor, secondColor.cgColor]
        if axis == .horizontal {
            gradient.locations = [0.0 , 1.0]
            gradient.startPoint = CGPoint(x: 0.05, y: 1.0)
            gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        } else if axis == .vertical {
            gradient.locations = [0.0 , 1.0]
            gradient.startPoint = CGPoint(x: 0.0, y: 0.05)
            gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        }
        gradient.frame = bounds
        layer.addSublayer(gradient)
    }
    
}
