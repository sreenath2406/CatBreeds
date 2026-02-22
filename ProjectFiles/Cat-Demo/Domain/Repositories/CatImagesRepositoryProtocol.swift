//
//  CatImagesRepositoryProtocol.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/21/26.
//

import Foundation

protocol CatImagesRepositoryProtocol {
    func fetchCatImage(breedId: String, completion: @escaping (Result<Data, Error>) -> Void)
}
