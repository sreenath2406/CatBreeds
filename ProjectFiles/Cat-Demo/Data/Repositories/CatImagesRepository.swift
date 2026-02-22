//
//  CatImagesRepository.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/21/26.
//

import Foundation

final class CatImagesRepository: CatImagesRepositoryProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchCatImage(breedId: String, completion: @escaping (Result<Data, Error>) -> Void) {
        apiClient.requestDecodable(CatAPIEndpoints.imageSearch(breedId: breedId)) { [weak self] (result: Result<[CatDetails], Error>) in
            guard let self else { return }
            switch result {
                case .success(let details):
                    guard let urlString = details.first?.url, let url = URL(string: urlString) else {
                        return completion(.failure(NetworkError.noData))
                    }
                    self.apiClient.requestData(url: url, completion: completion)

                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
}
