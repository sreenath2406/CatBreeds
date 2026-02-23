//
//  BreedDetailViewModel.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/22/26.
//

import Foundation

protocol BreedDetailViewModelDelegate: AnyObject {
    func viewModelDidStartImageFetch()
    func viewModelDidFetchImage(imageData: Data)
    func viewModelDidFailImageFetch(error: Error)
}

enum BreedDetailViewModelError: LocalizedError {
    case missingBreedID

    var errorDescription: String? {
        switch self {
            case .missingBreedID:
                return "This breed has no ID, so we can't fetch its image."
        }
    }
}

// Holds all the data and logic for the detail screen.
// No UIKit imports — the view controller is responsible for turning data into views.
final class BreedDetailViewModel {
    let breed: CatBreed

    private let fetchCatImageUseCase: FetchCatImageUseCaseProtocol
    weak var delegate: BreedDetailViewModelDelegate?

    private(set) var cachedImageData: Data?
    private var isFetchingImage = false

    var wikipediaURL: URL? {
        guard var raw = breed.wikipediaUrl?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else { return nil }
        if !raw.lowercased().hasPrefix("http://"), !raw.lowercased().hasPrefix("https://") {
            raw = "https://\(raw)"
        }
        return URL(string: raw)
    }

    init(breed: CatBreed, fetchCatImageUseCase: FetchCatImageUseCaseProtocol) {
        self.breed = breed
        self.fetchCatImageUseCase = fetchCatImageUseCase
    }

    // Maps a 1–5 API rating to the matching image asset name.
    // Returns nil if the value is missing or out of range.
    func ratingImageName(for value: Int?) -> String? {
        guard let v = value, (1...5).contains(v) else { return nil }
        return ["0-poor", "1-fair", "2-good", "3-very-good", "4-excellent"][v - 1]
    }

    func ratingText(for value: Int?) -> String {
        guard let v = value else { return "- / 5" }
        return "\(v) / 5"
    }

    // Fetches the breed image. Returns the cached copy if we've already loaded it.
    // Also guards against firing the same request twice
    func fetchImage() {
        if let cached = cachedImageData {
            delegate?.viewModelDidFetchImage(imageData: cached)
            return
        }

        guard !isFetchingImage else { return }

        guard let breedId = breed.id, !breedId.isEmpty else {
            delegate?.viewModelDidFailImageFetch(error: BreedDetailViewModelError.missingBreedID)
            return
        }

        isFetchingImage = true
        delegate?.viewModelDidStartImageFetch()

        fetchCatImageUseCase.execute(breedId: breedId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isFetchingImage = false
                switch result {
                    case .success(let data):
                        self.cachedImageData = data
                        self.delegate?.viewModelDidFetchImage(imageData: data)
                    case .failure(let error):
                        self.delegate?.viewModelDidFailImageFetch(error: error)
                }
            }
        }
    }
}
