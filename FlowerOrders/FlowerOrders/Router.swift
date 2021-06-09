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
    
    func toOrderDetailsViewController(order: Order, delegate: OrderDetailsViewModelDelegate?) {
        let viewModel = OrderDetailsViewModel(order: order, delegate: delegate, router: self)
        let viewController = OrderDetailsViewController(viewModel: viewModel)
        navController?.pushViewController(viewController, animated: true)
    }
    
    func errorAlert(errorMessage: String, handler: @escaping () -> Void) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            handler()
        })
        alertController.addAction(alertAction)
        
        navController?.present(alertController, animated: true)
    }
    
    func popViewController() {
        navController?.popViewController(animated: true)
    }
}
