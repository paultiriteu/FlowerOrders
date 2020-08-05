//
//  OrderModel.swift
//  FlowerOrders
//
//  Created by Paul Tiriteu on 05/08/2020.
//  Copyright © 2020 Paul Tiriteu. All rights reserved.
//

import CoreData

struct Order: Codable {
    var uid: Double
    var description: String
    var price: Double
    var recipient: String
    var sent: Bool
    
    func mapToCoreData() {
        let persistentOrder = CD_Order(context: PersistenceManager.shared.context)
        persistentOrder.uid = Int64(exactly: uid) ?? 0
        persistentOrder.orderDescription = description
        persistentOrder.price = Int64(exactly: price) ?? 0
        persistentOrder.recipient = recipient
        persistentOrder.sent = NSNumber(value: sent)
    }
}
