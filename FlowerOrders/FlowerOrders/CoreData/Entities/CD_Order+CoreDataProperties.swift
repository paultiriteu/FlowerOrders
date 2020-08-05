//
//  CD_Order+CoreDataProperties.swift
//  FlowerOrders
//
//  Created by Paul Tiriteu on 05/08/2020.
//  Copyright © 2020 Paul Tiriteu. All rights reserved.
//
//

import Foundation
import CoreData


extension CD_Order {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CD_Order> {
        return NSFetchRequest<CD_Order>(entityName: "CD_Order")
    }

    @NSManaged public var uid: Int64
    @NSManaged public var orderDescription: String
    @NSManaged public var price: Int64
    @NSManaged public var recipient: String
    @NSManaged public var sent: NSNumber

}
