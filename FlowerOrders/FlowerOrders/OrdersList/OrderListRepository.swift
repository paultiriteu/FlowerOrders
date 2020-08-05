//
//  OrderListRepository.swift
//  FlowerOrders
//
//  Created by Paul Tiriteu on 05/08/2020.
//  Copyright © 2020 Paul Tiriteu. All rights reserved.
//

import Foundation

class OrderListRepository {
    private let networking: Networking
    
    init(networking: Networking) {
        self.networking = networking
    }
    
    func getOrders(completion: @escaping () -> Void) {
        var didSaveContext = false
        networking.request(onSuccess: { (response: [Order]) in
            response.forEach { (order) in
                if PersistenceManager.shared.itemExists(id: order.uid, type: CD_Order.self) == false {
                    order.mapToCoreData()
                    PersistenceManager.shared.saveContext()
                    didSaveContext = true
                }
            }
            if !didSaveContext {
                completion()
            }
        }, onError: { errorMessage in
            
        })
    }
}
