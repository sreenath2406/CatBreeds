//
//  CatBreedsRepositoryProtocol.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/21/26.
//

import Foundation

protocol CatBreedsRepositoryProtocol {
    func fetchBreedsPage(limit: Int, page: Int, completion: @escaping (Result<[CatBreed], Error>) -> Void)
}
