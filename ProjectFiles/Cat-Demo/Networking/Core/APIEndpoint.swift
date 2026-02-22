//
//  APIEndpoint.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/21/26.
//

import Foundation

struct APIEndpoint {
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]
    
    init(path: String, method: HTTPMethod = .get, queryItems: [URLQueryItem] = []) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
    }
}
