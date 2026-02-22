//
//  NetworkError.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/21/26.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case transport(Error)
    case invalidResponse
    case httpStatus(Int)
    case noData
    case decoding(Error)
    case imageDecodingFailed
}
