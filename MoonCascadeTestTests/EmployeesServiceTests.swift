//
//  EmployeesServiceTests.swift
//  MoonCascadeTestTests
//
//  Created by Rinat Gabdullin on 12.04.2022.
//

import XCTest
@testable import MoonCascadeTest

class URLSessionStub: IURLSession {
    var responses = [URL: Data]()
    
    var calledURLs = [URL]()
    
    func data(from url: URL) async throws -> Data {
        calledURLs.append(url)
        
        if let response = responses[url] {
            return response
        }
        
        throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled)
    }
}

class EmployeesServiceTests: XCTestCase {

    var service: EmployeesService!
    var urlSessionStub = URLSessionStub()
    
    let url1 = URL(string: "https://example.com/1")!
    let url2 = URL(string: "https://example.com/2")!
    let url3 = URL(string: "https://example.com/3")!
    
    let response1Data = response1String.data(using: .utf8)
    let response2Data = response2String.data(using: .utf8)

    func testFetch() async throws {
        service = EmployeesService(urlSession: urlSessionStub, sources: [url1, url2])
        urlSessionStub.responses[url1] = response1Data
        urlSessionStub.responses[url2] = response2Data
        
        let fetched = try await service.fetchAll()
        XCTAssertEqual(fetched.count, 4)
        XCTAssertEqual(urlSessionStub.calledURLs, [url1, url2])
    }

    func testFetchAndRemoveDuplicates() async throws {
        service = EmployeesService(urlSession: urlSessionStub, sources: [url1, url2])
        urlSessionStub.responses[url1] = response1Data
        urlSessionStub.responses[url2] = response1Data
        let fetched = try await service.fetchAll()
        XCTAssertEqual(fetched.count, 2)
    }
    
    func testFetchWithInvalidResponse() async throws {
        service = EmployeesService(urlSession: urlSessionStub, sources: [url1, url2])
        urlSessionStub.responses[url1] = response1Data
        urlSessionStub.responses[url2] = invalidResponseString.data(using: .utf8)
        
        do {
            _ = try await service.fetchAll()
            XCTFail()
        } catch {
            // expected thrown error
        }
    }
}

let response1String =
"""
{
    "employees": [
        {
            "fname": "John",
            "lname": "Appleseed",
            "position": "IOS",
            "contact_details": {
                "email": "John-Appleseed@mac.com",
                "phone": "888 555 5512"
            }
        },
        {
            "fname": "Toomas-Anu",
            "lname": "Saar",
            "position": "TESTER",
            "contact_details": {
                "email": "toomas-anu.saar@example.eu"
            },
            "projects": [
                "Ontotop",
                "Namjob"
            ]
        }
]
}
"""

let response2String =
"""
{
    "employees": [
        {
            "fname": "Roman-Eve",
            "lname": "Poder",
            "position": "WEB",
            "contact_details": {
                "email": "roman-eve.parn-poder@example.com"
            },
            "projects": [
                "Truelax",
                "Alphaflex",
                "Alpha Sing",
                "Stantip",
                "Matjob",
                "Graveit",
                "Antax"
            ]
        },
        {
            "fname": "Margus-Diana",
            "lname": "Limus-Ots",
            "position": "SALES",
            "contact_details": {
                "email": "margus-diana.lohmus-ots@example.com"
            },
            "projects": [
                "Dankix",
                "Stan-Plus",
                "Ontotop",
                "Alpha Sing",
                "Matjob",
                "Konkeco",
                "Antax"
            ]
        }
]
}
"""

let invalidResponseString = "1"
