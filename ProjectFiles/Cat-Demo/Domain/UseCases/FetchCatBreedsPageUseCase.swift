//
//  FetchCatBreedsPageUseCase.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/21/26.
//

import Foundation

protocol FetchCatBreedsPageUseCaseProtocol {
    func execute(limit: Int, page: Int, completion: @escaping (Result<[CatBreed], Error>) -> Void)
}

final class FetchCatBreedsPageUseCase: FetchCatBreedsPageUseCaseProtocol {
    private let repository: CatBreedsRepositoryProtocol

    init(repository: CatBreedsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(limit: Int, page: Int, completion: @escaping (Result<[CatBreed], Error>) -> Void) {
        repository.fetchBreedsPage(limit: limit, page: page, completion: completion)
    }
}
