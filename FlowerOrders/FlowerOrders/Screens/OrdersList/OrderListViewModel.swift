//
//  OrderListViewModel.swift
//  FlowerOrders
//
//  Created by Paul Tiriteu on 05/08/2020.
//  Copyright © 2020 Paul Tiriteu. All rights reserved.
//

import Foundation

protocol OrderListViewModelDelegate: class {
    func orderListViewModel(_ orderListViewModel: OrderListViewModel, shouldUpdateView: Bool)
}

class OrderListViewModel {
    private let repository: OrderListRepository
    private let router: Router
    
    weak var delegate: OrderListViewModelDelegate?
    
    var orders = [Order]()
    var unsentOrders = [Order]() {
        didSet {
            delegate?.orderListViewModel(self, shouldUpdateView: false)
        }
    }
    var sentOrders = [Order]() {
        didSet {
            delegate?.orderListViewModel(self, shouldUpdateView: false)
        }
    }
    
    init(repository: OrderListRepository, router: Router) {
        self.repository = repository
        self.router = router
    }
    
    func getOrders(onError: (() -> Void)? = { }) {
        repository.getOrders(onError: { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.router.errorAlert(errorMessage: errorMessage, handler: {
                    if let closure = onError {
                        closure()
                    }
                })
            }
        })
    }
    
    func loadOrders(completion: @escaping () -> Void) {
        orders = []
        unsentOrders = []
        sentOrders = []
        PersistenceManager.shared.performBackgroundTask { [weak self] (context) in
            let cdOrders = context.fetch(CD_Order.self)?.sorted(by: { $1.uid > $0.uid }) ?? []
            cdOrders.forEach { (order) in
                self?.orders.append(Order(order: order))
                if order.sent == false {
                    self?.unsentOrders.append(Order(order: order))
                } else {
                    self?.sentOrders.append(Order(order: order))
                }
            }
            completion()
        }
    }
    
    func deliverOrder(at indexPath: IndexPath) {
        PersistenceManager.shared.performBackgroundTask { [weak self] (context) in
            if indexPath.section == 0 {
                guard var order = self?.unsentOrders[indexPath.row] else { return }
                let cdOrder = context.fetch(CD_Order.self, id: order.uid)
                cdOrder?.sent = true
                order.sent = true
                self?.moveOrderToSentArray(order: order)
            }
            context.saveContext()
        }
    }
    
    func moveOrderToSentArray(order: Order) {
        sentOrders.append(order)
        if let index = unsentOrders.firstIndex(where: { $0.uid == order.uid }) {
            unsentOrders.remove(at: index)
        }
    }
    
    func setSearchText(searchText: String) {
        let query = searchText.lowercased()
        
        unsentOrders = []
        sentOrders = []
        
        orders.forEach { (order) in
            if order.description.lowercased().contains(query) || order.recipient.lowercased().contains(query) || query == "" {
                order.sent ? sentOrders.append(order) : unsentOrders.append(order)
            }
        }
    }
    
    func toOrderDetailsViewController(indexPath: IndexPath) {
        let order = indexPath.section == 0 && !unsentOrders.isEmpty ? unsentOrders[indexPath.row] : sentOrders[indexPath.row]
        router.toOrderDetailsViewController(order: order, delegate: self)
    }
}

extension OrderListViewModel: OrderDetailsViewModelDelegate {
    func orderDetailsViewModel(_ orderDetailsViewModel: OrderDetailsViewModel, deliver order: Order) {
        guard var order = unsentOrders.first(where: { $0.uid == order.uid }) else { return }
        order.sent = true
        moveOrderToSentArray(order: order)
        
        delegate?.orderListViewModel(self, shouldUpdateView: true)
    }
}
