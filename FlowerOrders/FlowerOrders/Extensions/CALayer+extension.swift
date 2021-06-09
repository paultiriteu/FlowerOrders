//
//  CALayer+extension.swift
//  FlowerOrders
//
//  Created by Paul Tiriteu on 08/08/2020.
//  Copyright © 2020 Paul Tiriteu. All rights reserved.
//

import UIKit

extension CALayer {
    func applyShadow(color: UIColor = .black, alpha: Float = 0.2, x: CGFloat = 0, y: CGFloat = 9, blur: CGFloat = 15) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
    }
}
