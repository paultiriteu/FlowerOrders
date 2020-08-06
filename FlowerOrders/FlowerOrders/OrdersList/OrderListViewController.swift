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
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        refreshControl?.tintColor = .black
        
        NotificationCenter.default.addObserver(self, selector: #selector(displayLocalOrders), name: Notification.Name.NSManagedObjectContextDidSave, object: nil)
        displayLocalOrders()
        viewModel.getOrders(onError: {
            print("error retreiving data")
        })
    }
    
    @objc func refreshTableView() {
        viewModel.getOrders(onError: { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.refreshControl?.endRefreshing()
            }
        })
    }
    
    @objc private func displayLocalOrders() {
        viewModel.loadOrders()
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
}

extension OrderListViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderTableViewCell.className, for: indexPath) as? OrderTableViewCell else { return UITableViewCell() }
        cell.configure(order: viewModel.orders[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.orders.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [
            makeTrailingContextualAction(forRowAt: indexPath)
        ])
    }
    
    //MARK: - Contextual Actions
    private func makeTrailingContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        return UIContextualAction(style: .normal, title: "Delivered", handler: { action, swipeButton, completion in
            self.viewModel.deliverOrder(at: indexPath, completion: {
                completion(true)
            })
            print(self.viewModel.orders[indexPath.row])
        })
    }
}
