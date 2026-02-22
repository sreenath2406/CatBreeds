// Copyright © 2021 Intuit, Inc. All rights reserved.
import Foundation

protocol CatDataDelegate: AnyObject {
    func viewModelDidUpdateBreeds()
}

// Handles fetching and paginating the breeds list.
final class BreedsListViewModel {
    weak var catDataDelegate: CatDataDelegate?

    private let fetchBreedsPageUseCase: FetchCatBreedsPageUseCaseProtocol

    private let pageSize = 20
    private var currentPage = 0
    private var isLoadingPage = false
    private var reachedEnd = false

    private(set) var catBreeds: [CatBreed] = [] {
        didSet { catDataDelegate?.viewModelDidUpdateBreeds() }
    }

    init(fetchBreedsPageUseCase: FetchCatBreedsPageUseCaseProtocol) {
        self.fetchBreedsPageUseCase = fetchBreedsPageUseCase
    }

    // Clears existing results and starts over from page 0.
    func getBreeds() {
        currentPage = 0
        reachedEnd = false
        catBreeds = []
        loadNextPage()
    }

    // Loads the next page and appends to the list.
    // Does nothing if we're already waiting on a request or we've hit the end.
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
                        print(error.localizedDescription)
                }
            }
        }
    }
}
