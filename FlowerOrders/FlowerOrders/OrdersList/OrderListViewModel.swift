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
    private let router: Router
    
    var orders = [CD_Order]()
    var unsentOrders = [CD_Order]()
    var sentOrders = [CD_Order]()
    
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
        unsentOrders = []
        sentOrders = []
        PersistenceManager.shared.performBackgroundTask { [weak self] (context) in
            self?.orders = PersistenceManager.shared.context.fetch(CD_Order.self)?.sorted(by: { $1.uid > $0.uid }) ?? []
            self?.unsentOrders.append(contentsOf: self?.orders.filter({$0.sent == false}) ?? [])
            self?.sentOrders.append(contentsOf: self?.orders.filter({$0.sent == true}) ?? [])
            completion()
        }
    }
    
    func deliverOrder(at indexPath: IndexPath, completion: @escaping () -> Void) {
        PersistenceManager.shared.performBackgroundTask { [weak self] (context) in
            if indexPath.section == 0 {
                guard let order = self?.unsentOrders[indexPath.row] else { return }
                order.sent = true
                self?.sentOrders.append(order)
                if let index = self?.unsentOrders.firstIndex(of: order) {
                    self?.unsentOrders.remove(at: index)
                }
            }
            context.saveContext()
            completion()
        }
    }
    
    func toOrderDetailsViewController(indexPath: IndexPath) {
        let order = indexPath.section == 0 ? unsentOrders[indexPath.row] : sentOrders[indexPath.row]
        router.toOrderDetailsViewController(order: order)
    }
}
