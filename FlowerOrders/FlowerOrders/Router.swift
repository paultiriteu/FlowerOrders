//
//  Router.swift
//  FlowerOrders
//
//  Created by Paul Tiriteu on 05/08/2020.
//  Copyright © 2020 Paul Tiriteu. All rights reserved.
//

import UIKit

class Router {
    let networking = Networking()
    var navController: UINavigationController?
    
    func getInitialViewController() -> UIViewController {
        let repository = OrderListRepository(networking: networking)
        let viewModel = OrderListViewModel(repository: repository, router: self)
        let viewController = OrderListViewController(viewModel: viewModel)
        
        let navigationController = UINavigationController(rootViewController: viewController)
        navController = navigationController
        
        return navigationController
    }
    
    func toOrderDetailsViewController(order: CD_Order) {
        let viewModel = OrderDetailsViewModel(order: order)
        let viewController = OrderDetailsViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
}
