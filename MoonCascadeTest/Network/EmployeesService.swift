//
//  EmployeesProvider.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 13.03.2022.
//

import Foundation

protocol IEmployeesService {
    func fetchAll() async throws -> [Employee]
}

protocol IURLSession {
    func data(from url: URL) async throws -> Data
}

extension URLSession: IURLSession {
    public func data(from url: URL) async throws -> Data {
        try await data(from: url).0
    }
}

final class EmployeesService: IEmployeesService {
    
    let urlSession: IURLSession
    let sources: [URL]
    
    internal init(urlSession: IURLSession, sources: [URL]) {
        self.urlSession = urlSession
        self.sources = sources
    }
    
    func fetchAll() async throws -> [Employee] {
        var result = Set<Employee>()
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        for source in sources {
            // TODO: Replace serial request sending with concurrent
            let fetched = try await urlSession.data(from: source)
            let decoded = try decoder.decode(EmployeesResponse.self, from: fetched)
            result.formUnion(decoded.employees)
        }
        return Array(result)
    }
}
