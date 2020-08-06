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
    
    func mapToCoreData(context: NSManagedObjectContext) {
            if !context.itemExists(id: self.uid, type: CD_Order.self) {
                let persistentOrder = CD_Order(context: context)
                persistentOrder.uid = self.uid
                persistentOrder.orderDescription = self.description
                persistentOrder.price = self.price
                persistentOrder.recipient = self.recipient
                persistentOrder.sent = NSNumber(value: self.sent)
            }
    }
}
