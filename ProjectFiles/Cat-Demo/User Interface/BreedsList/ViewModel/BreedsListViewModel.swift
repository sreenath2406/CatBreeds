// Copyright © 2021 Intuit, Inc. All rights reserved.
import Foundation

protocol CatDataDelegate: AnyObject {
    func viewModelDidUpdateBreeds()
}

// Handles fetching and paginating the breeds list, plus name-based search.
final class BreedsListViewModel {
    weak var catDataDelegate: CatDataDelegate?

    private let fetchBreedsPageUseCase: FetchCatBreedsPageUseCaseProtocol
    private let searchCatBreedsUseCase: SearchCatBreedsUseCaseProtocol
    private let searchDebounceInterval: TimeInterval
    private let searchScheduler: DispatchQueue

    private let pageSize = 20
    private var currentPage = 0
    private var isLoadingPage = false
    private var reachedEnd = false

    // The full paginated list — never touched during search.
    private var allBreeds: [CatBreed] = []

    // Results coming back from the search endpoint.
    private var searchResults: [CatBreed] = []

    // Tracks whether we're in search mode or browse mode.
    private(set) var isSearchActive = false

    // Pending debounce work item — cancelled and replaced on every new keystroke.
    private var searchDebounceTask: DispatchWorkItem?

    // What the table view always reads from.
    var displayedBreeds: [CatBreed] {
        isSearchActive ? searchResults : allBreeds
    }

    init(
        fetchBreedsPageUseCase: FetchCatBreedsPageUseCaseProtocol,
        searchCatBreedsUseCase: SearchCatBreedsUseCaseProtocol,
        searchDebounceInterval: TimeInterval = 0.3,
        searchScheduler: DispatchQueue = .main
    ) {
        self.fetchBreedsPageUseCase = fetchBreedsPageUseCase
        self.searchCatBreedsUseCase = searchCatBreedsUseCase
        self.searchDebounceInterval = searchDebounceInterval
        self.searchScheduler = searchScheduler
    }

    // Clears existing results and starts over from page 0.
    func getBreeds() {
        currentPage = 0
        reachedEnd = false
        allBreeds = []
        catDataDelegate?.viewModelDidUpdateBreeds()
        loadNextPage()
    }

    // Loads the next page and appends to the list.
    // No-op while search is active so we don't mix results.
    func loadNextPage() {
        guard !isSearchActive, !isLoadingPage, !reachedEnd else { return }
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
                            self.allBreeds.append(contentsOf: pageBreeds)
                            self.catDataDelegate?.viewModelDidUpdateBreeds()
                        }

                    case .failure(let error):
                        print(error.localizedDescription)
                }
            }
        }
    }

    // Called by the VC on every search bar text change.
    // Debounces by 300ms so we don't fire a request on every keystroke.
    func search(query: String) {
        searchDebounceTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespaces)

        guard !trimmed.isEmpty else {
            // User cleared the bar — go back to browse mode immediately.
            isSearchActive = false
            searchResults = []
            catDataDelegate?.viewModelDidUpdateBreeds()
            return
        }

        let task = DispatchWorkItem { [weak self] in
            self?.performSearch(query: trimmed)
        }
        searchDebounceTask = task
        searchScheduler.asyncAfter(deadline: .now() + searchDebounceInterval, execute: task)
    }

    private func performSearch(query: String) {
        isSearchActive = true

        searchCatBreedsUseCase.execute(query: query) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                    case .success(let breeds):
                        self.searchResults = breeds
                        self.catDataDelegate?.viewModelDidUpdateBreeds()
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            }
        }
    }
}
