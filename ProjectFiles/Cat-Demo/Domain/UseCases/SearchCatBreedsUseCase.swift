//
//  SearchCatBreedsUseCase.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/22/26.
//

import Foundation

protocol SearchCatBreedsUseCaseProtocol {
    func execute(query: String, completion: @escaping (Result<[CatBreed], Error>) -> Void)
}

final class SearchCatBreedsUseCase: SearchCatBreedsUseCaseProtocol {
    private let repository: CatBreedsRepositoryProtocol

    init(repository: CatBreedsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(query: String, completion: @escaping (Result<[CatBreed], Error>) -> Void) {
        repository.searchBreeds(query: query, completion: completion)
    }
}
