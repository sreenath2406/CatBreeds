//
//  NetworkSpies.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/22/26.
//

import Foundation
@testable import Cat_Demo

final class APIClientSpy: APIClientProtocol {
    private(set) var capturedDecodablePath: String?
    private(set) var capturedDecodableQueryItems: [URLQueryItem] = []
    private(set) var capturedDataURL: URL?

    var decodableResultProvider: ((Any.Type) -> Result<Any, Error>)?
    var dataResult: Result<Data, Error> = .success(Data())

    func requestDecodable<T: Decodable>(_ endpoint: APIEndpoint, completion: @escaping (Result<T, Error>) -> Void) {
        capturedDecodablePath = endpoint.path
        capturedDecodableQueryItems = endpoint.queryItems
        if let provided = decodableResultProvider?(T.self) {
            switch provided {
                case .success(let value):
                    if let typed = value as? T {
                        completion(.success(typed))
                    } else {
                        completion(.failure(TestError.typeMismatch))
                    }
                case .failure(let error):
                    completion(.failure(error))
            }
            return
        }
        completion(.failure(TestError.missingStub))
    }

    func requestData(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        capturedDataURL = url
        completion(dataResult)
    }
}

final class URLSessioningSpy: URLSessioning {
    private(set) var capturedRequest: URLRequest?
    private(set) var capturedURL: URL?
    private(set) var requestTaskCreationCount = 0
    private(set) var urlTaskCreationCount = 0
    private lazy var noOpTask: URLSessionDataTask = {
        let request = URLRequest(url: URL(string: "about:blank")!)
        return URLSession.shared.dataTask(with: request)
    }()

    var requestCompletion: (@Sendable (Data?, URLResponse?, Error?) -> Void)?
    var urlCompletion: (@Sendable (Data?, URLResponse?, Error?) -> Void)?

    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        capturedRequest = request
        requestCompletion = completionHandler
        requestTaskCreationCount += 1
        return noOpTask
    }

    func dataTask(
        with url: URL,
        completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        capturedURL = url
        urlCompletion = completionHandler
        urlTaskCreationCount += 1
        return noOpTask
    }
}
