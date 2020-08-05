//
//  Networking.swift
//  FlowerOrders
//
//  Created by Paul Tiriteu on 05/08/2020.
//  Copyright © 2020 Paul Tiriteu. All rights reserved.
//

import Foundation


class Networking {
    let session = URLSession.shared
    let baseUrl = "https://demo3221589.mockable.io/"
    
    func request<ResponseType: Codable>(onSuccess: @escaping (ResponseType) -> Void, onError: @escaping (String) -> Void) {
        guard let url = URL(string: baseUrl) else {
            onError("Request URL is not valid")
            return
        }
        
        let task = session.dataTask(with: url) { (data, response, error) in
            guard let safeData = data else {
                onError("Data cannot be decoded")
                return
            }
            
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(ResponseType.self, from: safeData) {
                onSuccess(decoded)
            } else {
                onError("Data cannot be decoded")
            }
        }
        task.resume()
    }
}
