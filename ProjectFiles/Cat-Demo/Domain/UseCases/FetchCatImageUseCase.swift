//
//  FetchCatImageUseCase.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/21/26.
//

import Foundation

protocol FetchCatImageUseCaseProtocol {
    func execute(breedId: String, completion: @escaping (Result<Data, Error>) -> Void)
}

final class FetchCatImageUseCase: FetchCatImageUseCaseProtocol {
    private let repository: CatImagesRepositoryProtocol
    
    init(repository: CatImagesRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(breedId: String, completion: @escaping (Result<Data, Error>) -> Void) {
        repository.fetchCatImage(breedId: breedId, completion: completion)
    }
}
