//
//  EmployeesServiceStub.swift
//  MoonCascadeTestTests
//
//  Created by Rinat Gabdullin on 14.04.2022.
//

import XCTest
@testable import MoonCascadeTest

class EmployeesServiceStub: IEmployeesService {
    var returnData = [Employee]()
    
    var errorToThrow: Error?
    
    func fetchAll() async throws -> [Employee] {
        try await Task.sleep(nanoseconds: 100_000_000) // Wait for 0.1 second
        
        if let errorToThrow = errorToThrow {
            throw errorToThrow
        }
        
        return returnData
    }
}
