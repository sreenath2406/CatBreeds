//
//  APIClientTests.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/22/26.
//

import XCTest
@testable import Cat_Demo

final class APIClientTests: XCTestCase {
    func testRequestDecodableBuildsURLWithPathAndQueryAndResumesTask() {
        let sessionSpy = URLSessioningSpy()
        let sut = APIClient(
            baseURL: URL(string: "https://api.thecatapi.com")!,
            session: sessionSpy,
            callbackQueue: .main
        )
        let endpoint = APIEndpoint(
            path: "/v1/breeds",
            queryItems: [URLQueryItem(name: "limit", value: "20")]
        )

        sut.requestDecodable(endpoint) { (_: Result<[CatBreed], Error>) in }

        XCTAssertEqual(sessionSpy.requestTaskCreationCount, 1)
        XCTAssertEqual(sessionSpy.capturedRequest?.url?.absoluteString, "https://api.thecatapi.com/v1/breeds?limit=20")
    }

    func testRequestDecodableMapsNoData() {
        let sessionSpy = URLSessioningSpy()
        let sut = APIClient(session: sessionSpy, callbackQueue: .main)
        let exp = expectation(description: "completion")
        let url = URL(string: "https://api.thecatapi.com/v1/breeds")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)

        sut.requestDecodable(CatAPIEndpoints.breeds(limit: 20, page: 0)) { (result: Result<[CatBreed], Error>) in
            if case .failure(let error as NetworkError) = result {
                if case .noData = error {} else { XCTFail("Expected noData") }
            } else {
                XCTFail("Expected failure")
            }
            exp.fulfill()
        }
        sessionSpy.requestCompletion?(nil, response, nil)

        wait(for: [exp], timeout: 1)
    }

    func testRequestDecodableMapsDecodingError() {
        let sessionSpy = URLSessioningSpy()
        let sut = APIClient(session: sessionSpy, callbackQueue: .main)
        let exp = expectation(description: "completion")
        let url = URL(string: "https://api.thecatapi.com/v1/breeds")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)

        sut.requestDecodable(CatAPIEndpoints.breeds(limit: 20, page: 0)) { (result: Result<[CatBreed], Error>) in
            if case .failure(let error as NetworkError) = result {
                if case .decoding = error {} else { XCTFail("Expected decoding") }
            } else {
                XCTFail("Expected failure")
            }
            exp.fulfill()
        }
        sessionSpy.requestCompletion?(TestFixtures.invalidJSONData(), response, nil)

        wait(for: [exp], timeout: 1)
    }

    func testRequestDecodableSuccessDecodesModel() {
        let sessionSpy = URLSessioningSpy()
        let sut = APIClient(session: sessionSpy, callbackQueue: .main)
        let exp = expectation(description: "completion")
        let url = URL(string: "https://api.thecatapi.com/v1/breeds")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)

        sut.requestDecodable(CatAPIEndpoints.breeds(limit: 20, page: 0)) { (result: Result<[CatBreed], Error>) in
            if case .success(let breeds) = result {
                XCTAssertEqual(breeds.first?.id, "abys")
            } else {
                XCTFail("Expected success")
            }
            exp.fulfill()
        }
        sessionSpy.requestCompletion?(TestFixtures.validBreedsJSONData(), response, nil)

        wait(for: [exp], timeout: 1)
    }

    func testRequestDataSuccessReturnsData() {
        let sessionSpy = URLSessioningSpy()
        let sut = APIClient(session: sessionSpy, callbackQueue: .main)
        let exp = expectation(description: "completion")
        let url = URL(string: "https://cdn2.thecatapi.com/images/cat.jpg")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let payload = Data([1, 2, 3, 4])

        sut.requestData(url: url) { result in
            if case .success(let data) = result {
                XCTAssertEqual(data, payload)
            } else {
                XCTFail("Expected success")
            }
            exp.fulfill()
        }
        sessionSpy.urlCompletion?(payload, response, nil)

        wait(for: [exp], timeout: 1)
    }
}
