//
//  UIView+ET.swift
//  bili
//
//  Created by DJ on 2024/8/15.
//


import UIKit

extension UIView {
    
    func setupGradientShadow() {
        // 创建渐变层
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.5).cgColor] // 从黑色到透明的渐变
        gradientLayer.startPoint = CGPoint(x: 0, y: 0) // 渐变开始点
        gradientLayer.endPoint = CGPoint(x: 0, y: 1) // 渐变结束点
        
        // 将渐变层添加到视图的图层中
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

// 使用示例
//let myView = GradientShadowView(frame: CGRect(x: 50, y: 50, width: 200, height: 200))
//myView.backgroundColor = .white // 设置背景颜色
