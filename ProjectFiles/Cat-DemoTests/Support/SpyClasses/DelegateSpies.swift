//
//  DelegateSpies.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/22/26.
//

import Foundation
@testable import Cat_Demo

final class SpyCatDataDelegate: CatDataDelegate {
    private(set) var updateCallCount = 0

    func viewModelDidUpdateBreeds() {
        updateCallCount += 1
    }
}

final class SpyBreedDetailDelegate: BreedDetailViewModelDelegate {
    private(set) var didStartCount = 0
    private(set) var fetchedImages: [Data] = []
    private(set) var errors: [Error] = []

    func viewModelDidStartImageFetch() {
        didStartCount += 1
    }

    func viewModelDidFetchImage(imageData: Data) {
        fetchedImages.append(imageData)
    }

    func viewModelDidFailImageFetch(error: Error) {
        errors.append(error)
    }
}
