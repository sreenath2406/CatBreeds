// Copyright © 2021 Intuit, Inc. All rights reserved.
import Foundation
import UIKit

/// Basic Delegate interface to send messages
protocol CatDataDelegate {
    func breedsChangedNotification()
    func imageChangedNotification()
}

/// View model
class ViewModel {
    var catDataDelegate: CatDataDelegate?

    private let fetchAllBreedsUseCase: FetchAllCatBreedsUseCaseProtocol
    private let fetchCatImageUseCase: FetchCatImageUseCaseProtocol

    init(
        fetchAllBreedsUseCase: FetchAllCatBreedsUseCaseProtocol,
        fetchCatImageUseCase: FetchCatImageUseCaseProtocol
    ) {
        self.fetchAllBreedsUseCase = fetchAllBreedsUseCase
        self.fetchCatImageUseCase = fetchCatImageUseCase
    }

    /// Array of cat breeds
    var catBreeds: [CatBreed]? {
        didSet {
            self.catDataDelegate?.breedsChangedNotification()
        }
    }

    /// Image of the cat
    var catImage: UIImage? {
        didSet {
            self.catDataDelegate?.imageChangedNotification()
        }
    }

    /// Get the breeds
    func getBreeds() {
        fetchAllBreedsUseCase.execute { [weak self] result in
            switch result
            {
                case .success(let breeds):
                    DispatchQueue.main.async {
                        self?.catBreeds = breeds
                    }

                case .failure(let error):
                    print(error)
            }
        }
    }

    func getCatImage(breedId: String) {
        fetchCatImageUseCase.execute(breedId: breedId) { [weak self] result in
            switch result
            {
                case .success(let image):
                    DispatchQueue.main.async {
                        self?.catImage = image
                    }

                case .failure(let error):
                    print(error)
            }
        }
    }
}
