//
//  FetchCatBreedsPageUseCase.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/21/26.
//
//  Uses CatBreedFilterService (Core ML) to classify search queries and filter
//  breeds locally. Falls back to name-based filtering when confidence is low.
//
//

import Foundation

protocol FilterCatBreedsUseCaseProtocol {
    func execute(query: String, breeds: [CatBreed], completion: @escaping (Result<[CatBreed], Error>) -> Void)
}

final class FilterCatBreedsUseCase: FilterCatBreedsUseCaseProtocol {
    private let filterService: CatBreedFilterService

    init(filterService: CatBreedFilterService) {
        self.filterService = filterService
    }

    func execute(query: String, breeds: [CatBreed], completion: @escaping (Result<[CatBreed], Error>) -> Void) {
        let normalized = query
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !normalized.isEmpty else {
            completion(.success([]))
            return
        }

        // Try Core ML classification first
        if let label = filterService.classify(query: normalized) {
            let filtered = filterService.filter(breeds: breeds, byLabel: label)
            completion(.success(filtered))
            return
        }

        // Fallback: filter by name when confidence is low
        let nameFiltered = breeds.filter { breed in
            breed.name?.lowercased().contains(normalized) ?? false
        }
        completion(.success(nameFiltered))
    }
}
