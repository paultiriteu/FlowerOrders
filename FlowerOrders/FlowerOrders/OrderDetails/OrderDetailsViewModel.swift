//
//  OrderDetailsViewModel.swift
//  FlowerOrders
//
//  Created by Paul Tiriteu on 06/08/2020.
//  Copyright © 2020 Paul Tiriteu. All rights reserved.
//

import Foundation

protocol OrderDetailsViewModelDelegate: class {
    func orderDetailsViewModel(_ orderDetailsViewModel: OrderDetailsViewModel, deliver order: Order)
}

class OrderDetailsViewModel {
    private let router: Router
    private weak var delegate: OrderDetailsViewModelDelegate?
    var order: Order
    
    init(order: Order, delegate: OrderDetailsViewModelDelegate?, router: Router) {
        self.order = order
        self.delegate = delegate
        self.router = router
    }
    
    func deliverOrder() {
        PersistenceManager.shared.performBackgroundTask { [weak self] (context) in
            guard
                let orderId = self?.order.uid,
                let cdOrder = context.fetch(CD_Order.self, id: orderId) else { return }
            cdOrder.sent = true
            context.saveContext()
        }
        order.sent = true
        delegate?.orderDetailsViewModel(self, deliver: order)
        router.popViewController()
    }
}
