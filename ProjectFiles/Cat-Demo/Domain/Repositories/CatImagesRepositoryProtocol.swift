//
//  CatImagesRepositoryProtocol.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/21/26.
//

import UIKit

protocol CatImagesRepositoryProtocol {
    func fetchCatImage(breedId: String, completion: @escaping (Result<UIImage, Error>) -> Void)
}
