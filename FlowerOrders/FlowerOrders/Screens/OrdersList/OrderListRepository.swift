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
    
    func getOrders(onError: @escaping (String) -> Void) {
        networking.request(onSuccess: { (response: [Order]) in
            PersistenceManager.shared.performBackgroundTask { (context) in
                context.deleteAll(CD_Order.self)
                response.forEach { (order) in
                    order.mapToCoreData(context: context)
                }
                context.saveContext()
            }
        }, onError: { errorMessage in
            onError(errorMessage)
        })
    }
}
