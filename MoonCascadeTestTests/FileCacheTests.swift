//
//  FileCacheTests.swift
//  MoonCascadeTestTests
//
//  Created by Rinat Gabdullin on 12.04.2022.
//

import XCTest
@testable import MoonCascadeTest

class FileCacheTests: XCTestCase {

    var cache: FileCache!
    
    override func setUpWithError() throws {
        cache = try FileCache()
    }

    func testSavingAndReading() throws {
        let uuid = UUID()
        cache.save(data: uuid, key: "test")
        XCTAssertEqual(cache.read(key: "test"), uuid)
    }
    
    func testReadingWithoutSavedData() {
        let data: UUID? = cache.read(key: "test without data")
        XCTAssertEqual(data, nil)
    }
    
    func testReplacingData() {
        let uuid = UUID()
        cache.save(data: UUID(), key: "test")
        cache.save(data: uuid, key: "test")
        XCTAssertEqual(cache.read(key: "test"), uuid)
    }
    
    func testConcurrency() {
        
        let queue = DispatchQueue(label: "serial")
        let group = DispatchGroup()
        
        for i in 0...10 {
            group.enter()
            queue.async {
                self.cache.save(data: String(i), key: "test")
                let result: String? = self.cache.read(key: "test")
                XCTAssertEqual(result, String(i))
                group.leave()
            }
        }
        
        let exp = expectation(description: "saving completion")
        group.notify(queue: .main) {
            let result: String? = self.cache.read(key: "test")
            exp.fulfill()
            XCTAssertEqual(result, "10")
        }
        
        waitForExpectations(timeout: 10)
    }
}
