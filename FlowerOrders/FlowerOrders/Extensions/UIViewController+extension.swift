//
//  UIViewController+extension.swift
//  FlowerOrders
//
//  Created by Paul Tiriteu on 06/08/2020.
//  Copyright © 2020 Paul Tiriteu. All rights reserved.
//

import UIKit

extension UIViewController {
    class var className: String {
        return String(describing: self)
    }
}
