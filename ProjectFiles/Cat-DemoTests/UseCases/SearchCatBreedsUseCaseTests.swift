//
//  SearchCatBreedsUseCaseTests.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/22/26.
//

import XCTest
@testable import Cat_Demo

final class SearchCatBreedsUseCaseTests: XCTestCase {
    func testExecuteForwardsToRepository() {
        let repositorySpy = CatBreedsRepositorySpy()
        repositorySpy.searchResult = .success([TestFixtures.makeBreed(name: "Siberian")])
        let sut = SearchCatBreedsUseCase(repository: repositorySpy)
        let exp = expectation(description: "completion")

        sut.execute(query: "sib") { result in
            if case .success(let breeds) = result {
                XCTAssertEqual(breeds.first?.name, "Siberian")
            } else {
                XCTFail("Expected success")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
        XCTAssertEqual(repositorySpy.searchCalls, ["sib"])
    }
}
