//
//  CatAPIEndpoints.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/21/26.
//

import Foundation

enum CatAPIEndpoints {
    static func breeds(limit: Int, page: Int) -> APIEndpoint {
        APIEndpoint(
            path: "/v1/breeds",
            queryItems: [
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "page", value: String(page))
            ]
        )
    }
    
    static func imageSearch(breedId: String) -> APIEndpoint {
        APIEndpoint(
            path: "/v1/images/search",
            queryItems: [
                URLQueryItem(name: "breed_ids", value: breedId),
                URLQueryItem(name: "include_breeds", value: "true")
            ]
        )
    }
}
