//
//  CatBreedsRepositoryTests.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/22/26.
//

import XCTest
@testable import Cat_Demo

final class CatBreedsRepositoryTests: XCTestCase {
    func testFetchBreedsPageUsesBreedsEndpoint() {
        let apiClientSpy = APIClientSpy()
        apiClientSpy.decodableResultProvider = { _ in .success([TestFixtures.makeBreed()]) }
        let sut = CatBreedsRepository(apiClient: apiClientSpy)
        let exp = expectation(description: "completion")

        sut.fetchBreedsPage(limit: 20, page: 1) { result in
            if case .success(let breeds) = result {
                XCTAssertEqual(breeds.count, 1)
            } else {
                XCTFail("Expected success")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
        XCTAssertEqual(apiClientSpy.capturedDecodablePath, "/v1/breeds")
        XCTAssertEqual(apiClientSpy.capturedDecodableQueryItems.first(where: { $0.name == "limit" })?.value, "20")
        XCTAssertEqual(apiClientSpy.capturedDecodableQueryItems.first(where: { $0.name == "page" })?.value, "1")
    }

    func testSearchBreedsUsesSearchEndpoint() {
        let apiClientSpy = APIClientSpy()
        apiClientSpy.decodableResultProvider = { _ in .success([TestFixtures.makeBreed(name: "Siberian")]) }
        let sut = CatBreedsRepository(apiClient: apiClientSpy)
        let exp = expectation(description: "completion")

        sut.searchBreeds(query: "sib") { result in
            if case .success(let breeds) = result {
                XCTAssertEqual(breeds.first?.name, "Siberian")
            } else {
                XCTFail("Expected success")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
        XCTAssertEqual(apiClientSpy.capturedDecodablePath, "/v1/breeds/search")
        XCTAssertEqual(apiClientSpy.capturedDecodableQueryItems.first(where: { $0.name == "q" })?.value, "sib")
    }
}
