//
//  EmployeeListPresenterTests.swift
//  MoonCascadeTestTests
//
//  Created by Rinat Gabdullin on 12.04.2022.
//

import XCTest
import Combine
@testable import MoonCascadeTest

let stubEmployee1 = Employee(fname: "aa", lname: "1", contactDetails: .init(email: "email@example.com"), position: .ios, projects: nil)
let stubEmployee2 = Employee(fname: "ab", lname: "2", contactDetails: .init(email: "2"), position: .ios, projects: ["Test"])
let stubEmployee3 = Employee(fname: "bb", lname: "3", contactDetails: .init(email: "3"), position: .ios, projects: ["5"])

class EmployeeListPresenterTests: XCTestCase {
    
    var subscriptions = Set<AnyCancellable>()
    var presenter: EmployeeListPresenter!
    var cache = CacheStub()
    var service = EmployeesServiceStub()
    
    override func setUpWithError() throws {
        service.returnData.removeAll()
        cache.dictionary.removeAll()
        presenter = EmployeeListPresenter(service: service, cache: cache)
    }

    override func tearDown() {
        subscriptions.removeAll()
    }
    
    func testDataFromCache() throws {
        cache.dictionary[presenter.cacheKey] = [stubEmployee1]
        
        let expectation = expectation(description: "return")
        
        presenter
            .startSendingData()
            .receive(on: DispatchQueue.main)
            .sink { value in
                let viewModel = ListViewModel(name: stubEmployee1.fullName, index: 0)
                XCTAssertEqual(value.employeesByPosition, [.ios: [viewModel]])
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 1)
    }
    
    func testDataFromNetwork() async {
        service.returnData = [stubEmployee1]
        
        let expectation = expectation(description: "return")
        
        presenter
            .startSendingData()
            .sink { value in
                
                if value.employeesByPosition.isEmpty {
                    // Return empty data from cache
                    XCTAssertEqual(value.employeesByPosition, [:])
                    return
                }
                
                let viewModel = ListViewModel(name: stubEmployee1.fullName, index: 0)
                XCTAssertEqual(value.employeesByPosition, [.ios: [viewModel]])
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        await waitForExpectations(timeout: 1)
        
        let cached = cache.dictionary[presenter.cacheKey] as! [Employee]
        XCTAssert(cached.contains(stubEmployee1), "Cache must contain data retrivied from network")
    }
    
    func testReloadFromNetwork() async {
        service.returnData = [stubEmployee1]
        
        let expectation = expectation(description: "return")
        var isFullfilled = false
        
        var returnedValue = [EmployeePosition: [ListViewModel]]()
        
        presenter
            .startSendingData()
            .sink { value in
                returnedValue = value.employeesByPosition
                
                if !isFullfilled && !value.employeesByPosition.isEmpty {
                    isFullfilled = true
                    expectation.fulfill()
                }
            }
            .store(in: &subscriptions)

        await waitForExpectations(timeout: 1)
        
        let viewModels = service.returnData.makeListViewModels()
        XCTAssertEqual(returnedValue, [.ios: viewModels])
        
        let array = [stubEmployee2, stubEmployee3]
        service.returnData = array

        // When `call reloadData()`
        await presenter.reloadData()
        
        // Then `return updated data`
        XCTAssertEqual(returnedValue, [.ios: array.makeListViewModels()])
    }
    
    func testThrowingErrors() async {
        let localizedDescription = "Error text"
        
        let error = NSError(domain: NSURLErrorDomain,
                            code: 999,
                            userInfo: [NSLocalizedDescriptionKey : localizedDescription])
        
        service.errorToThrow = error
        let errorExpectation = expectation(description: "error expectation")
        
        presenter
            .$lastError
            .dropFirst() // Combine sends initial empty value, so skip it
            .sink { errorText in
                XCTAssertEqual(errorText, localizedDescription)
                errorExpectation.fulfill()
            }
            .store(in: &subscriptions)
        
        _ = presenter.startSendingData()
        
        await waitForExpectations(timeout: 1)
    }
    
    func testSearch() async {
        service.returnData = [stubEmployee1, stubEmployee2, stubEmployee3]
        
        var returnedValue = [ListViewModel]()
        
        presenter
            .startSendingData()
            .drop(while: { $0.employeesByPosition.isEmpty }) // Drop empty data from cache
            .sink { table in
                returnedValue = table.employeesByPosition[.ios] ?? []
            }
            .store(in: &subscriptions)
            
        await presenter.reloadData()
        XCTAssertEqual(returnedValue.count, 3) // Returned users: "aa", "ab", "bb" (all)
        
        // Search by name:
        presenter.searchString = "a"
        XCTAssertEqual(returnedValue.count, 2) // Returned users: "aa", "ab"
        
        presenter.searchString = "aa"
        XCTAssertEqual(returnedValue.count, 1)
        XCTAssertEqual(returnedValue.first?.name, "aa 1") // Returned users: "aa"
        
        // Search by project:
        presenter.searchString = "Test"
        XCTAssertEqual(returnedValue.count, 1)
        XCTAssertEqual(returnedValue.first?.name, "ab 2")
    
        // Search by email:
        presenter.searchString = "email@example"
        XCTAssertEqual(returnedValue.count, 1)
        XCTAssertEqual(returnedValue.first?.name, "aa 1")
    
        // Search with no results
        presenter.searchString = "string"
        XCTAssertEqual(returnedValue.count, 0)
    }
}

extension Array where Element == Employee {
    func makeListViewModels() -> [ListViewModel] {
        enumerated().map { ListViewModel(name: $0.element.fullName, index: $0.offset) }
    }
}
