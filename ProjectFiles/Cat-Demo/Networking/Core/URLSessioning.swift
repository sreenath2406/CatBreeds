//
//  URLSessioning.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/21/26.
//

import Foundation

protocol URLSessioning {
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask
    
    func dataTask(
        with url: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask
}

extension URLSession: URLSessioning {}
