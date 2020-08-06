//
//  OrderListViewModel.swift
//  FlowerOrders
//
//  Created by Paul Tiriteu on 05/08/2020.
//  Copyright © 2020 Paul Tiriteu. All rights reserved.
//

import Foundation

class OrderListViewModel {
    private let repository: OrderListRepository
    
    var orders = [CD_Order]()
    
    init(repository: OrderListRepository) {
        self.repository = repository
    }
    
    func getOrders(onError: @escaping () -> Void) {
        repository.getOrders(onError: {
            onError()
        })
    }
    
    func loadOrders() {
        PersistenceManager.shared.context.perform {
            self.orders = PersistenceManager.shared.context.fetch(CD_Order.self)?.sorted(by: { $1.uid > $0.uid }) ?? []
        }
    }
    
    func deliverOrder(at indexPath: IndexPath, completion: @escaping () -> Void) {
        PersistenceManager.shared.performBackgroundTask { [weak self] (context) in
            guard
                let orderId = self?.orders[indexPath.row].uid,
                let orderToUpdate = context.fetch(CD_Order.self, id: orderId) else { return }
            
            orderToUpdate.sent = true
            self?.orders[indexPath.row] = orderToUpdate
            context.saveContext()
        }
    }
}
