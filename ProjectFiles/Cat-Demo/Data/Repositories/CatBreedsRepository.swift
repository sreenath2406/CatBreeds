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
    
    func fetchAllBreeds(completion: @escaping (Result<[CatBreed], Error>) -> Void) {
        apiClient.requestDecodable(CatAPIEndpoints.allBreeds()) { (result: Result<[CatBreed], Error>) in
            switch result {
                case .success(let breeds):
                    let sorted = breeds.sorted { ($0.name ?? "") < ($1.name ?? "") }
                    completion(.success(sorted))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
}
