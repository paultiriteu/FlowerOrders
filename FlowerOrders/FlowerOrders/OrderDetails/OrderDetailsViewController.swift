//
//  OrderDetailsViewController.swift
//  FlowerOrders
//
//  Created by Paul Tiriteu on 06/08/2020.
//  Copyright © 2020 Paul Tiriteu. All rights reserved.
//

import UIKit

class OrderDetailsViewController: UIViewController {
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var deliverButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    private let viewModel: OrderDetailsViewModel
    
    @IBAction func deliverButtonAction(_ sender: Any) {
        viewModel.deliverOrder()
    }
    
    init(viewModel: OrderDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: OrderDetailsViewController.className, bundle: Bundle(for: OrderDetailsViewController.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        let order = viewModel.order
        if let orderId = Int(exactly: order.uid) {
            title = "Order ID: \(orderId)"
        } else {
            title = "Order details"
        }
        
        if viewModel.order.sent == false {
            deliverButton.setTitle("Set as delivered", for: .normal)
            deliverButton.backgroundColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1)
            deliverButton.isEnabled = true
        } else {
            deliverButton.setTitle("Order delivered", for: .normal)
            deliverButton.backgroundColor = .lightGray
            deliverButton.isEnabled = false
        }
        
        nameLabel.text = "Recipient's name is \(order.recipient)"
        descriptionLabel.text = order.description
        priceLabel.text = "$\(order.price)"
    }
}
