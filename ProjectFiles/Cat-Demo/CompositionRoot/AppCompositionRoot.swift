//
//  AppCompositionRoot.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/21/26.
//

import Foundation

/// This is where we set up the app’s dependencies.
///
/// Since this project is small (just two screens),  kept things simple
///
/// In a larger app — especially one using VIPER — each module would usually
/// handle its own setup in its Router or Builder.

final class AppCompositionRoot {
    static let shared = AppCompositionRoot()

    private init() {}

    private lazy var apiClient: APIClientProtocol = APIClient()
    private lazy var breedsRepository: CatBreedsRepositoryProtocol = CatBreedsRepository(apiClient: apiClient)
    private lazy var imagesRepository: CatImagesRepositoryProtocol = CatImagesRepository(apiClient: apiClient)

    func makeFetchCatBreedsPageUseCase() -> FetchCatBreedsPageUseCaseProtocol {
        FetchCatBreedsPageUseCase(repository: breedsRepository)
    }

    func makeFetchCatImageUseCase() -> FetchCatImageUseCaseProtocol {
        FetchCatImageUseCase(repository: imagesRepository)
    }

    func makeBreedsListViewModel() -> BreedsListViewModel {
        BreedsListViewModel(fetchBreedsPageUseCase: makeFetchCatBreedsPageUseCase())
    }

    func makeBreedDetailViewModel(breed: CatBreed) -> BreedDetailViewModel {
        BreedDetailViewModel(
            breed: breed,
            fetchCatImageUseCase: makeFetchCatImageUseCase()
        )
    }
}
