//
//  APIClient.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/21/26.
//

import Foundation

protocol APIClientProtocol {
    /// Completion is invoked on the API client's configured callback queue.
    func requestDecodable<T: Decodable>(_ endpoint: APIEndpoint, completion: @escaping (Result<T, Error>) -> Void)
    /// Completion is invoked on the API client's configured callback queue.
    func requestData(url: URL, completion: @escaping (Result<Data, Error>) -> Void)
}

final class APIClient: APIClientProtocol {
    private let baseURL: URL
    private let session: URLSessioning
    private let decoder: JSONDecoder
    private let callbackQueue: DispatchQueue
    
    init(
        baseURL: URL = URL(string: "https://api.thecatapi.com")!,
        session: URLSessioning = URLSession.shared,
        decoder: JSONDecoder = JSONDecoder(),
        callbackQueue: DispatchQueue = .global(qos: .userInitiated)
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
        self.callbackQueue = callbackQueue
    }
    
    func requestDecodable<T: Decodable>(_ endpoint: APIEndpoint, completion: @escaping (Result<T, Error>) -> Void) {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            return callbackQueue.async { completion(.failure(NetworkError.invalidURL)) }
        }
        
        components.path = endpoint.path
        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }
        
        guard let url = components.url else {
            return callbackQueue.async { completion(.failure(NetworkError.invalidURL)) }
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        session.dataTask(with: request) { [callbackQueue, decoder] data, response, error in
            let result: Result<T, Error>
            
            if let error {
                result = .failure(NetworkError.transport(error))
            } else if let http = response as? HTTPURLResponse {
                if !(200..<300).contains(http.statusCode) {
                    result = .failure(NetworkError.httpStatus(http.statusCode))
                } else if let data {
                    do {
                        let decoded = try decoder.decode(T.self, from: data)
                        result = .success(decoded)
                    } catch {
                        result = .failure(NetworkError.decoding(error))
                    }
                } else {
                    result = .failure(NetworkError.noData)
                }
            } else {
                result = .failure(NetworkError.invalidResponse)
            }
            
            callbackQueue.async { completion(result) }
        }.resume()
    }
    
    func requestData(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        session.dataTask(with: url) { [callbackQueue] data, response, error in
            let result: Result<Data, Error>
            
            if let error {
                result = .failure(NetworkError.transport(error))
            } else if let http = response as? HTTPURLResponse {
                if !(200..<300).contains(http.statusCode) {
                    result = .failure(NetworkError.httpStatus(http.statusCode))
                } else if let data {
                    result = .success(data)
                } else {
                    result = .failure(NetworkError.noData)
                }
            } else {
                result = .failure(NetworkError.invalidResponse)
            }
            
            callbackQueue.async { completion(result) }
        }.resume()
    }
}
