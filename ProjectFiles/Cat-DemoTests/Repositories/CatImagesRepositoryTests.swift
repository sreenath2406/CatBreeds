//
//  CatImagesRepositoryTests.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/22/26.
//

import XCTest
@testable import Cat_Demo

final class CatImagesRepositoryTests: XCTestCase {
    func testFetchCatImageRequestsImageSearchThenDownloadsImageData() {
        let apiClientSpy = APIClientSpy()
        let expectedData = Data([1, 2, 3])
        apiClientSpy.decodableResultProvider = { _ in .success([TestFixtures.makeCatDetails(url: "https://cdn2.thecatapi.com/images/cat.jpg")]) }
        apiClientSpy.dataResult = .success(expectedData)
        let sut = CatImagesRepository(apiClient: apiClientSpy)
        let exp = expectation(description: "completion")

        sut.fetchCatImage(breedId: "abys") { result in
            if case .success(let data) = result {
                XCTAssertEqual(data, expectedData)
            } else {
                XCTFail("Expected success")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
        XCTAssertEqual(apiClientSpy.capturedDecodablePath, "/v1/images/search")
        XCTAssertEqual(apiClientSpy.capturedDecodableQueryItems.first(where: { $0.name == "breed_ids" })?.value, "abys")
        XCTAssertEqual(apiClientSpy.capturedDataURL?.absoluteString, "https://cdn2.thecatapi.com/images/cat.jpg")
    }

    func testFetchCatImageReturnsNoDataWhenSearchHasNoURL() {
        let apiClientSpy = APIClientSpy()
        apiClientSpy.decodableResultProvider = { _ in .success([TestFixtures.makeCatDetails(url: "")]) }
        let sut = CatImagesRepository(apiClient: apiClientSpy)
        let exp = expectation(description: "completion")

        sut.fetchCatImage(breedId: "abys") { result in
            if case .failure(let error as NetworkError) = result {
                if case .noData = error {} else { XCTFail("Expected noData") }
            } else {
                XCTFail("Expected noData error")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }
}
