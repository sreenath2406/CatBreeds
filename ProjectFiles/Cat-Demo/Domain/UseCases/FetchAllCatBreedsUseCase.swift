//
//  FetchAllCatBreedsUseCase.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/21/26.
//

import Foundation

protocol FetchAllCatBreedsUseCaseProtocol {
    func execute(completion: @escaping (Result<[CatBreed], Error>) -> Void)
}

final class FetchAllCatBreedsUseCase: FetchAllCatBreedsUseCaseProtocol {
    private let repository: CatBreedsRepositoryProtocol
    
    init(repository: CatBreedsRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(completion: @escaping (Result<[CatBreed], Error>) -> Void) {
        repository.fetchAllBreeds(completion: completion)
    }
}
