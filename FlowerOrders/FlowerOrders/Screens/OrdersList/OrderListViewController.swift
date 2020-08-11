//
//  OrderListViewController.swift
//  FlowerOrders
//
//  Created by Paul Tiriteu on 05/08/2020.
//  Copyright © 2020 Paul Tiriteu. All rights reserved.
//

import UIKit



class OrderListViewController: UIViewController {
    private let viewModel: OrderListViewModel
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search..."
        searchBar.sizeToFit()
        searchBar.backgroundColor = .white
        searchBar.returnKeyType = .done
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.delegate = self
        
        return searchBar
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UINib(nibName: OrderTableViewCell.className, bundle: Bundle(for: OrderTableViewCell.self)), forCellReuseIdentifier: OrderTableViewCell.className)
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        refreshControl.tintColor = .black
        return refreshControl
    }()
    
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
        navigationController?.navigationBar.standardAppearance.shadowColor = .clear
        
        configureSearchBar()
        configureTableView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(displayLocalOrders), name: Notification.Name.NSManagedObjectContextDidSave, object: nil)

        viewModel.delegate = self
        viewModel.getOrders()
        displayLocalOrders()
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        
        tableView.addSubview(refreshControl)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureSearchBar() {
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            searchBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50)
        ])
        view.layoutIfNeeded()
    }
    
    @objc func refreshTableView() {
        viewModel.getOrders(onError: { [weak self] in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }
        })
    }
    
    @objc private func displayLocalOrders() {
        viewModel.loadOrders {
            DispatchQueue.main.async { [weak self] in
                self?.refreshControl.endRefreshing()
            }
        }
    }
}

extension OrderListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.toOrderDetailsViewController(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderTableViewCell.className, for: indexPath) as? OrderTableViewCell else { return UITableViewCell() }
        if indexPath.section == 0 && !viewModel.unsentOrders.isEmpty {
            cell.configure(order: viewModel.unsentOrders[indexPath.row])
        } else if !viewModel.sentOrders.isEmpty {
            cell.configure(order: viewModel.sentOrders[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfRows(in: section)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section == 0 && !viewModel.unsentOrders.isEmpty else { return nil }
        return UISwipeActionsConfiguration(actions: [
            makeTrailingContextualAction(forRowAt: indexPath)
        ])
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let height: CGFloat = 30
        let width = UIScreen.main.bounds.width
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        headerView.backgroundColor = .white
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        label.textColor = .black
        label.text = section == 0 && !viewModel.unsentOrders.isEmpty ? "Orders" : "Sent orders"
        if viewModel.sentOrders.isEmpty {
            label.text = "Orders"
        }
        headerView.addSubview(label)
        
        return headerView
    }
    
    //MARK: - Contextual Actions
    private func makeTrailingContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Deliver", handler: { [weak self] action, swipeButton, completion in
            self?.viewModel.deliverOrder(at: indexPath)
            self?.searchBar.text = nil
        })
        action.backgroundColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1)
        return action
    }
}

extension OrderListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.setSearchText(searchText: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

extension OrderListViewController: OrderListViewModelDelegate {
    func orderListViewModel(_ orderListViewModel: OrderListViewModel, shouldUpdateView: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            
            if shouldUpdateView {
                self?.searchBar.text = nil
            }
        }
    }
}
