//
//  FetchCatImageUseCaseTests.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/22/26.
//

import XCTest
@testable import Cat_Demo

final class FetchCatImageUseCaseTests: XCTestCase {
    func testExecuteForwardsToRepository() {
        let repositorySpy = CatImagesRepositorySpy()
        let data = TestFixtures.makeImageData()
        repositorySpy.result = .success(data)
        let sut = FetchCatImageUseCase(repository: repositorySpy)
        let exp = expectation(description: "completion")

        sut.execute(breedId: "abys") { result in
            if case .success(let returnedData) = result {
                XCTAssertEqual(returnedData, data)
            } else {
                XCTFail("Expected success")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
        XCTAssertEqual(repositorySpy.fetchCalls, ["abys"])
    }
}
