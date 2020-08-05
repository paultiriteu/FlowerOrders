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
        let viewModel = OrderListViewModel(repository: repository)
        let viewController = OrderListViewController(viewModel: viewModel)
        
        let navigationController = UINavigationController(rootViewController: viewController)
        navController = navigationController
        
        return navigationController
    }
}
