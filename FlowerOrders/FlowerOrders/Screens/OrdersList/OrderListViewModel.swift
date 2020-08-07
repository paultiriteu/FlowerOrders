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
    
    var orders = [CD_Order]()
    var unsentOrders = [Order]()
    var sentOrders = [Order]()
    
    init(repository: OrderListRepository, router: Router) {
        self.repository = repository
        self.router = router
    }
    
    func getOrders(onError: @escaping () -> Void) {
        repository.getOrders(onError: {
            onError()
        })
    }
    
    func loadOrders(completion: @escaping () -> Void) {
        orders = []
        unsentOrders = []
        sentOrders = []
        PersistenceManager.shared.performBackgroundTask { [weak self] (context) in
            self?.orders = context.fetch(CD_Order.self)?.sorted(by: { $1.uid > $0.uid }) ?? []
            self?.orders.forEach { (order) in
                if order.sent == false {
                    self?.unsentOrders.append(Order(order: order))
                } else {
                    self?.sentOrders.append(Order(order: order))
                }
            }
            completion()
        }
    }
    
    func deliverOrder(at indexPath: IndexPath, completion: @escaping () -> Void) {
        PersistenceManager.shared.performBackgroundTask { [weak self] (context) in
            if indexPath.section == 0 {
                guard var order = self?.unsentOrders[indexPath.row] else { return }
                let cdOrder = context.fetch(CD_Order.self, id: order.uid)
                cdOrder?.sent = true
                order.sent = true
                self?.sentOrders.append(order)
                if let index = self?.unsentOrders.firstIndex(where: { $0.uid == order.uid }) {
                    self?.unsentOrders.remove(at: index)
                }
            }
            context.saveContext()
            completion()
        }
    }
    
    func toOrderDetailsViewController(indexPath: IndexPath) {
        let order = indexPath.section == 0 ? unsentOrders[indexPath.row] : sentOrders[indexPath.row]
        router.toOrderDetailsViewController(order: order, delegate: self)
    }
}

extension OrderListViewModel: OrderDetailsViewModelDelegate {
    func orderDetailsViewModel(_ orderDetailsViewModel: OrderDetailsViewModel, deliver order: Order) {
        guard var order = unsentOrders.first(where: { $0.uid == order.uid }) else { return }
        order.sent = true
        sentOrders.append(order)
        if let index = unsentOrders.firstIndex(where: { $0.uid == order.uid }) {
            unsentOrders.remove(at: index)
        }
        
        delegate?.orderListViewModel(self, shouldUpdateView: true)
    }
}
