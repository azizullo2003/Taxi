//
//  NetworkService.swift
//  JSONWebinar
//
//  Created by Алексей Пархоменко on 06/10/2019.
//  Copyright © 2019 Алексей Пархоменко. All rights reserved.
//

import Foundation

class NetworkService {
    
    func request(urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else { return }
                completion(.success(data))
            }
        }.resume()
    }
}
