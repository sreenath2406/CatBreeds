// Copyright © 2021 Intuit, Inc. All rights reserved.
import Foundation
import UIKit

/// Delegate that the ViewModel uses to notify its owner of state changes.
protocol CatDataDelegate: AnyObject {
    func viewModelDidUpdateBreeds()
    func viewModelDidFetchImage()
}

/// View model for the breeds list screen.
///
/// All published state (`catBreeds`, `catImage`) is assigned on the main thread.
/// Paging state is also mutated on the main thread to avoid data races.
class ViewModel {
    weak var catDataDelegate: CatDataDelegate?

    private let fetchBreedsPageUseCase: FetchCatBreedsPageUseCaseProtocol
    private let fetchCatImageUseCase: FetchCatImageUseCaseProtocol

    /// Number of breeds to request per page from the API.
    private let pageSize = 20

    // All paging state is read and written on the main thread.
    private var currentPage = 0
    private var isLoadingPage = false
    private var reachedEnd = false

    init(
        fetchBreedsPageUseCase: FetchCatBreedsPageUseCaseProtocol,
        fetchCatImageUseCase: FetchCatImageUseCaseProtocol
    ) {
        self.fetchBreedsPageUseCase = fetchBreedsPageUseCase
        self.fetchCatImageUseCase = fetchCatImageUseCase
    }

    /// Accumulated list of cat breeds loaded so far.
    var catBreeds: [CatBreed] = [] {
        didSet { catDataDelegate?.viewModelDidUpdateBreeds() }
    }

    /// Most recently fetched cat image.
    var catImage: UIImage? {
        didSet { catDataDelegate?.viewModelDidFetchImage() }
    }

    /// Resets paging state and loads the first page.
    func getBreeds() {
        currentPage = 0
        reachedEnd = false
        catBreeds = []
        loadNextPage()
    }

    /// Fetches the next page and appends results. No-op if already loading or at end.
    func loadNextPage() {
        guard !isLoadingPage, !reachedEnd else { return }
        isLoadingPage = true

        fetchBreedsPageUseCase.execute(limit: pageSize, page: currentPage) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoadingPage = false

                switch result {
                    case .success(let pageBreeds):
                        if pageBreeds.isEmpty {
                            self.reachedEnd = true
                        } else {
                            self.currentPage += 1
                            self.catBreeds.append(contentsOf: pageBreeds)
                        }

                    case .failure(let error):
                        print(error)
                }
            }
        }
    }

    func getCatImage(breedId: String) {
        fetchCatImageUseCase.execute(breedId: breedId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let image):
                        self?.catImage = image
                    case .failure(let error):
                        print(error)
                }
            }
        }
    }
}
