//
//  BreedsListViewModelTests.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/22/26.
//

import XCTest
@testable import Cat_Demo

final class BreedsListViewModelTests: XCTestCase {
    func testGetBreedsRequestsFirstPageWithDefaultPageSize() {
        let fetchSpy = FetchCatBreedsPageUseCaseSpy()
        let searchSpy = SearchCatBreedsUseCaseSpy()
        let sut = BreedsListViewModel(
            fetchBreedsPageUseCase: fetchSpy,
            searchCatBreedsUseCase: searchSpy,
            searchDebounceInterval: 0,
            searchScheduler: .main
        )
        
        sut.getBreeds()
        
        XCTAssertEqual(fetchSpy.executeCalls.count, 1)
        XCTAssertEqual(fetchSpy.executeCalls.first?.limit, 20)
        XCTAssertEqual(fetchSpy.executeCalls.first?.page, 0)
    }
    
    func testLoadNextPageAppendsAndRequestsNextPage() {
        let fetchSpy = FetchCatBreedsPageUseCaseSpy()
        let searchSpy = SearchCatBreedsUseCaseSpy()
        let sut = BreedsListViewModel(
            fetchBreedsPageUseCase: fetchSpy,
            searchCatBreedsUseCase: searchSpy,
            searchDebounceInterval: 0,
            searchScheduler: .main
        )
        let exp = expectation(description: "next page request")
        
        sut.getBreeds()
        fetchSpy.complete(with: .success([TestFixtures.makeBreed(id: "abys")]))
        DispatchQueue.main.async {
            sut.loadNextPage()
            XCTAssertEqual(fetchSpy.executeCalls.count, 2)
            XCTAssertEqual(fetchSpy.executeCalls[1].page, 1)
            XCTAssertEqual(sut.displayedBreeds.count, 1)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func testLoadNextPageStopsAfterEmptyPage() {
        let fetchSpy = FetchCatBreedsPageUseCaseSpy()
        let searchSpy = SearchCatBreedsUseCaseSpy()
        let sut = BreedsListViewModel(
            fetchBreedsPageUseCase: fetchSpy,
            searchCatBreedsUseCase: searchSpy,
            searchDebounceInterval: 0,
            searchScheduler: .main
        )
        
        sut.getBreeds()
        fetchSpy.complete(with: .success([]))
        sut.loadNextPage()
        
        XCTAssertEqual(fetchSpy.executeCalls.count, 1)
    }
    
    func testSearchTrimsQueryAndUsesSearchUseCase() {
        let fetchSpy = FetchCatBreedsPageUseCaseSpy()
        let searchSpy = SearchCatBreedsUseCaseSpy()
        let sut = BreedsListViewModel(
            fetchBreedsPageUseCase: fetchSpy,
            searchCatBreedsUseCase: searchSpy,
            searchDebounceInterval: 0,
            searchScheduler: .main
        )
        let exp = expectation(description: "search executes")
        
        sut.search(query: "  aby  ")
        DispatchQueue.main.async {
            XCTAssertEqual(searchSpy.executeCalls, ["aby"])
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func testSearchClearDisablesSearchAndRestoresBrowseList() {
        let fetchSpy = FetchCatBreedsPageUseCaseSpy()
        let searchSpy = SearchCatBreedsUseCaseSpy()
        let sut = BreedsListViewModel(
            fetchBreedsPageUseCase: fetchSpy,
            searchCatBreedsUseCase: searchSpy,
            searchDebounceInterval: 0,
            searchScheduler: .main
        )
        let exp = expectation(description: "search clear")
        
        sut.getBreeds()
        fetchSpy.complete(with: .success([TestFixtures.makeBreed(id: "abys", name: "Abyssinian")]))
        sut.search(query: "abc")
        DispatchQueue.main.async {
            searchSpy.complete(with: .success([]))
            sut.search(query: "   ")
            XCTAssertFalse(sut.isSearchActive)
            XCTAssertEqual(sut.displayedBreeds.count, 1)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func testSearchDebounceUsesLatestQueryOnly() {
        let fetchSpy = FetchCatBreedsPageUseCaseSpy()
        let searchSpy = SearchCatBreedsUseCaseSpy()
        let scheduler = DispatchQueue(label: "search.scheduler")
        let sut = BreedsListViewModel(
            fetchBreedsPageUseCase: fetchSpy,
            searchCatBreedsUseCase: searchSpy,
            searchDebounceInterval: 0.05,
            searchScheduler: scheduler
        )
        let exp = expectation(description: "latest query only")
        
        sut.search(query: "a")
        sut.search(query: "ab")
        sut.search(query: "aby")
        
        scheduler.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(searchSpy.executeCalls, ["aby"])
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
}
