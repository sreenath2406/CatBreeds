//
//  CatImagesRepository.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/21/26.
//

import Foundation
import UIKit

final class CatImagesRepository: CatImagesRepositoryProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchCatImage(breedId: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        apiClient.requestDecodable(CatAPIEndpoints.imageSearch(breedId: breedId)) { (result: Result<[CatDetails], Error>) in
            switch result {
                case .success(let details):
                    guard let urlString = details.first?.url, let url = URL(string: urlString) else {
                        return completion(.failure(NetworkError.noData))
                    }
                    self.apiClient.requestData(url: url) { dataResult in
                        switch dataResult {
                            case .success(let data):
                                guard let image = UIImage(data: data) else {
                                    return completion(.failure(NetworkError.imageDecodingFailed))
                                }
                                completion(.success(image))
                            case .failure(let error):
                                completion(.failure(error))
                        }
                    }

                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
}
