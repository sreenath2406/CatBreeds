//
//  FetchCatBreedsPageUseCaseTests.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/22/26.
//

import XCTest
@testable import Cat_Demo

final class FetchCatBreedsPageUseCaseTests: XCTestCase {
    func testExecuteForwardsToRepository() {
        let repositorySpy = CatBreedsRepositorySpy()
        repositorySpy.fetchPageResult = .success([TestFixtures.makeBreed()])
        let sut = FetchCatBreedsPageUseCase(repository: repositorySpy)
        let exp = expectation(description: "completion")

        sut.execute(limit: 20, page: 2) { result in
            if case .success(let breeds) = result {
                XCTAssertEqual(breeds.count, 1)
            } else {
                XCTFail("Expected success")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
        XCTAssertEqual(repositorySpy.fetchPageCalls.count, 1)
        XCTAssertEqual(repositorySpy.fetchPageCalls.first?.limit, 20)
        XCTAssertEqual(repositorySpy.fetchPageCalls.first?.page, 2)
    }
}
