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
    
    func getOrders(completion: @escaping () -> Void) {
        repository.getOrders(completion: completion)
    }
    
    func loadOrders() {
        orders = PersistenceManager.shared.fetch(CD_Order.self)
    }
}
