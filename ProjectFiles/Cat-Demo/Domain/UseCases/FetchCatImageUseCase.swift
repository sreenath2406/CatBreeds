//
//  FetchCatImageUseCase.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/21/26.
//

import UIKit

protocol FetchCatImageUseCaseProtocol {
    func execute(breedId: String, completion: @escaping (Result<UIImage, Error>) -> Void)
}

final class FetchCatImageUseCase: FetchCatImageUseCaseProtocol {
    private let repository: CatImagesRepositoryProtocol
    
    init(repository: CatImagesRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(breedId: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        repository.fetchCatImage(breedId: breedId, completion: completion)
    }
}
