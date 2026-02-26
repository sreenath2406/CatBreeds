//
//  UseCaseSpies.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/22/26.
//

import Foundation
@testable import Cat_Demo

final class FetchCatBreedsPageUseCaseSpy: FetchCatBreedsPageUseCaseProtocol {
    private(set) var executeCalls: [(limit: Int, page: Int)] = []
    var pendingCompletion: ((Result<[CatBreed], Error>) -> Void)?

    func execute(
        limit: Int,
        page: Int,
        completion: @escaping (Result<[CatBreed], Error>) -> Void
    ) {
        executeCalls.append((limit: limit, page: page))
        pendingCompletion = completion
    }

    func complete(with result: Result<[CatBreed], Error>) {
        pendingCompletion?(result)
    }
}

final class SearchCatBreedsUseCaseSpy: SearchCatBreedsUseCaseProtocol {
    private(set) var executeCalls: [String] = []
    var pendingCompletion: ((Result<[CatBreed], Error>) -> Void)?

    func execute(
        query: String,
        completion: @escaping (Result<[CatBreed], Error>) -> Void
    ) {
        executeCalls.append(query)
        pendingCompletion = completion
    }

    func complete(with result: Result<[CatBreed], Error>) {
        pendingCompletion?(result)
    }
}

final class FilterCatBreedsUseCaseSpy: FilterCatBreedsUseCaseProtocol {
    private(set) var executeCalls: [(query: String, breeds: [CatBreed])] = []
    var pendingCompletion: ((Result<[CatBreed], Error>) -> Void)?

    func execute(
        query: String,
        breeds: [CatBreed],
        completion: @escaping (Result<[CatBreed], Error>) -> Void
    ) {
        executeCalls.append((query, breeds))
        pendingCompletion = completion
    }

    func complete(with result: Result<[CatBreed], Error>) {
        pendingCompletion?(result)
    }
}

final class FetchCatImageUseCaseSpy: FetchCatImageUseCaseProtocol {
    private(set) var executeCalls: [String] = []
    var pendingCompletion: ((Result<Data, Error>) -> Void)?

    func execute(
        breedId: String,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        executeCalls.append(breedId)
        pendingCompletion = completion
    }

    func complete(with result: Result<Data, Error>) {
        pendingCompletion?(result)
    }
}
