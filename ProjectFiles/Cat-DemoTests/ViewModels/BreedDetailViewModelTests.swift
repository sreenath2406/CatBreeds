//
//  BreedDetailViewModelTests.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/22/26.
//

import XCTest
@testable import Cat_Demo

final class BreedDetailViewModelTests: XCTestCase {
    func testWikipediaURLReturnsNilWhenMissing() {
        let sut = BreedDetailViewModel(
            breed: TestFixtures.makeBreed(wikipediaUrl: nil),
            fetchCatImageUseCase: FetchCatImageUseCaseSpy()
        )

        XCTAssertNil(sut.wikipediaURL)
    }

    func testWikipediaURLReturnsNilForBlankValue() {
        let sut = BreedDetailViewModel(
            breed: TestFixtures.makeBreed(wikipediaUrl: "   "),
            fetchCatImageUseCase: FetchCatImageUseCaseSpy()
        )

        XCTAssertNil(sut.wikipediaURL)
    }

    func testWikipediaURLUsesValueAsIsWhenSchemeExists() {
        let sut = BreedDetailViewModel(
            breed: TestFixtures.makeBreed(wikipediaUrl: "https://en.wikipedia.org/wiki/Abyssinian_(cat)"),
            fetchCatImageUseCase: FetchCatImageUseCaseSpy()
        )

        XCTAssertEqual(sut.wikipediaURL?.absoluteString, "https://en.wikipedia.org/wiki/Abyssinian_(cat)")
    }

    func testRatingImageNameReturnsExpectedAssetsForValidRange() {
        let sut = BreedDetailViewModel(
            breed: TestFixtures.makeBreed(),
            fetchCatImageUseCase: FetchCatImageUseCaseSpy()
        )

        XCTAssertEqual(sut.ratingImageName(for: 1), "0-poor")
        XCTAssertEqual(sut.ratingImageName(for: 2), "1-fair")
        XCTAssertEqual(sut.ratingImageName(for: 3), "2-good")
        XCTAssertEqual(sut.ratingImageName(for: 4), "3-very-good")
        XCTAssertEqual(sut.ratingImageName(for: 5), "4-excellent")
    }

    func testRatingImageNameReturnsNilForMissingOrOutOfRangeValues() {
        let sut = BreedDetailViewModel(
            breed: TestFixtures.makeBreed(),
            fetchCatImageUseCase: FetchCatImageUseCaseSpy()
        )

        XCTAssertNil(sut.ratingImageName(for: nil))
        XCTAssertNil(sut.ratingImageName(for: 0))
        XCTAssertNil(sut.ratingImageName(for: 6))
    }

    func testRatingTextReturnsDashForNilValue() {
        let sut = BreedDetailViewModel(
            breed: TestFixtures.makeBreed(),
            fetchCatImageUseCase: FetchCatImageUseCaseSpy()
        )

        XCTAssertEqual(sut.ratingText(for: nil), "- / 5")
    }

    func testRatingTextFormatsValue() {
        let sut = BreedDetailViewModel(
            breed: TestFixtures.makeBreed(),
            fetchCatImageUseCase: FetchCatImageUseCaseSpy()
        )

        XCTAssertEqual(sut.ratingText(for: 4), "4 / 5")
    }

    func testFetchImageMissingBreedIDCallsFailureDelegate() {
        let imageUseCaseSpy = FetchCatImageUseCaseSpy()
        let sut = BreedDetailViewModel(
            breed: TestFixtures.makeBreed(id: nil),
            fetchCatImageUseCase: imageUseCaseSpy
        )
        let delegate = SpyBreedDetailDelegate()
        sut.delegate = delegate
        
        sut.fetchImage()
        
        XCTAssertEqual(imageUseCaseSpy.executeCalls.count, 0)
        XCTAssertEqual(delegate.errors.count, 1)
    }
    
    func testFetchImageSuccessCachesDataAndAvoidsSecondUseCaseCall() {
        let imageUseCaseSpy = FetchCatImageUseCaseSpy()
        let sut = BreedDetailViewModel(
            breed: TestFixtures.makeBreed(id: "abys"),
            fetchCatImageUseCase: imageUseCaseSpy
        )
        let delegate = SpyBreedDetailDelegate()
        sut.delegate = delegate
        let exp = expectation(description: "success callback")
        
        sut.fetchImage()
        imageUseCaseSpy.complete(with: .success(TestFixtures.makeImageData()))
        
        DispatchQueue.main.async {
            sut.fetchImage()
            XCTAssertEqual(imageUseCaseSpy.executeCalls.count, 1)
            XCTAssertEqual(delegate.didStartCount, 1)
            XCTAssertEqual(delegate.fetchedImages.count, 2)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func testFetchImageWhileFetchingIgnoresDuplicateCall() {
        let imageUseCaseSpy = FetchCatImageUseCaseSpy()
        let sut = BreedDetailViewModel(
            breed: TestFixtures.makeBreed(id: "abys"),
            fetchCatImageUseCase: imageUseCaseSpy
        )
        
        sut.fetchImage()
        sut.fetchImage()
        
        XCTAssertEqual(imageUseCaseSpy.executeCalls.count, 1)
    }
}
