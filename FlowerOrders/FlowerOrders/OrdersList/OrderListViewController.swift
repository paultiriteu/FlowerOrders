//
//  OrderListViewController.swift
//  FlowerOrders
//
//  Created by Paul Tiriteu on 05/08/2020.
//  Copyright © 2020 Paul Tiriteu. All rights reserved.
//

import UIKit

class OrderListViewController: UITableViewController {
    private let viewModel: OrderListViewModel
    
    init(viewModel: OrderListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: OrderTableViewCell.className, bundle: Bundle(for: OrderTableViewCell.self)), forCellReuseIdentifier: OrderTableViewCell.className)
        
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave), name: Notification.Name.NSManagedObjectContextDidSave, object: nil)
        viewModel.getOrders {
            self.contextDidSave()
        }
    }
    
    @objc private func contextDidSave() {
        viewModel.loadOrders()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension OrderListViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderTableViewCell.className, for: indexPath) as? OrderTableViewCell else { return UITableViewCell() }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.orders.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
