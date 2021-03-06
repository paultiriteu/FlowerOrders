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
    var photoUrl: String
    var sent: Bool
    
    init(order: CD_Order) {
        self.uid = order.uid
        self.description = order.orderDescription
        self.price = order.price
        self.recipient = order.recipient
        self.photoUrl = order.photoUrl
        self.sent = order.sent.boolValue
    }
    
    enum CodingKeys: String, CodingKey {
        case uid, description, price, recipient, sent
        case photoUrl = "photo_url"
    }
    
    func mapToCoreData(context: NSManagedObjectContext) {
            if !context.itemExists(id: self.uid, type: CD_Order.self) {
                let persistentOrder = CD_Order(context: context)
                persistentOrder.uid = self.uid
                persistentOrder.orderDescription = self.description
                persistentOrder.price = self.price
                persistentOrder.recipient = self.recipient
                persistentOrder.photoUrl = self.photoUrl
                persistentOrder.sent = NSNumber(value: self.sent)
            }
    }
    
}

extension Order: Equatable {
    static func == (lhs: Order, rhs: Order) -> Bool {
        return
            lhs.uid == rhs.uid &&
            lhs.description == rhs.description &&
            lhs.price == rhs.price &&
            lhs.recipient == rhs.recipient &&
            lhs.photoUrl == rhs.photoUrl &&
            lhs.sent == rhs.sent
    }
}
