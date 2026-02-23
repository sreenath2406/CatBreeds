//
//  RepositorySpies.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/22/26.
//

import Foundation
@testable import Cat_Demo

final class CatBreedsRepositorySpy: CatBreedsRepositoryProtocol {
    private(set) var fetchPageCalls: [(limit: Int, page: Int)] = []
    private(set) var searchCalls: [String] = []

    var fetchPageResult: Result<[CatBreed], Error> = .success([])
    var searchResult: Result<[CatBreed], Error> = .success([])

    func fetchBreedsPage(limit: Int, page: Int, completion: @escaping (Result<[CatBreed], Error>) -> Void) {
        fetchPageCalls.append((limit: limit, page: page))
        completion(fetchPageResult)
    }

    func searchBreeds(query: String, completion: @escaping (Result<[CatBreed], Error>) -> Void) {
        searchCalls.append(query)
        completion(searchResult)
    }
}

final class CatImagesRepositorySpy: CatImagesRepositoryProtocol {
    private(set) var fetchCalls: [String] = []
    var result: Result<Data, Error> = .success(Data())

    func fetchCatImage(breedId: String, completion: @escaping (Result<Data, Error>) -> Void) {
        fetchCalls.append(breedId)
        completion(result)
    }
}
