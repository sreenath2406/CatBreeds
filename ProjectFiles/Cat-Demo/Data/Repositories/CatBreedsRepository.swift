//
//  CatBreedsRepository.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/21/26.
//

import Foundation

final class CatBreedsRepository: CatBreedsRepositoryProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func fetchBreedsPage(limit: Int, page: Int, completion: @escaping (Result<[CatBreed], Error>) -> Void) {
        apiClient.requestDecodable(CatAPIEndpoints.breeds(limit: limit, page: page), completion: completion)
    }

    func searchBreeds(query: String, completion: @escaping (Result<[CatBreed], Error>) -> Void) {
        apiClient.requestDecodable(CatAPIEndpoints.breedSearch(query: query), completion: completion)
    }
}
