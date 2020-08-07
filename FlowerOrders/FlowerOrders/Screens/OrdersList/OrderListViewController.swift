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
        title = "Your orders list"
        navigationController?.navigationBar.standardAppearance.backgroundColor = .white
        configureTableView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(displayLocalOrders), name: Notification.Name.NSManagedObjectContextDidSave, object: nil)
        viewModel.getOrders(onError: {
            print("error retreiving data")
        })
        displayLocalOrders()
    }
    
    private func configureTableView() {
        viewModel.delegate = self
        tableView.register(UINib(nibName: OrderTableViewCell.className, bundle: Bundle(for: OrderTableViewCell.self)), forCellReuseIdentifier: OrderTableViewCell.className)
        tableView.separatorStyle = .none
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        refreshControl?.tintColor = .black
    }
    
    @objc func refreshTableView() {
        viewModel.getOrders(onError: { [weak self] in
            DispatchQueue.main.async {
                self?.refreshControl?.endRefreshing()                
            }
        })
    }
    
    @objc private func displayLocalOrders() {
        viewModel.loadOrders {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }
}

extension OrderListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.toOrderDetailsViewController(indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderTableViewCell.className, for: indexPath) as? OrderTableViewCell else { return UITableViewCell() }
        if indexPath.section == 0 {
            cell.configure(order: viewModel.unsentOrders[indexPath.row])
        } else {
            cell.configure(order: viewModel.sentOrders[indexPath.row])
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? viewModel.unsentOrders.count : viewModel.sentOrders.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sentOrders.isEmpty ? 1 : 2
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section == 0 else { return nil }
        return UISwipeActionsConfiguration(actions: [
            makeTrailingContextualAction(forRowAt: indexPath)
        ])
    }
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return section == 0 ? "Orders" : "Sent orders"
//    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let height: CGFloat = 30
        let width = UIScreen.main.bounds.width
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        headerView.backgroundColor = .white
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        label.textColor = .black
        label.text = section == 0 ? "Orders" : "Sent orders"
        headerView.addSubview(label)
        
        return headerView
    }
    
    //MARK: - Contextual Actions
    private func makeTrailingContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Deliver", handler: { [weak self] action, swipeButton, completion in
            self?.viewModel.deliverOrder(at: indexPath, completion: {
                DispatchQueue.main.async {
                    self?.tableView.reloadData()                    
                }
            })
        })
        action.backgroundColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1)
        return action
    }
}


extension OrderListViewController: OrderListViewModelDelegate {
    func orderListViewModel(_ orderListViewModel: OrderListViewModel, shouldUpdateView: Bool) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
