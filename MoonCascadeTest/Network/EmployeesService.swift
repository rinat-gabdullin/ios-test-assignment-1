//
//  EmployeesProvider.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 13.03.2022.
//

import Foundation

class EmployeesService {
    
    let urlSession: URLSession
    let sources: [URL]
    
    internal init(urlSession: URLSession, sources: [URL]) {
        self.urlSession = urlSession
        self.sources = sources
    }
    
    func fetchAll() async throws -> [Employee] {
        var result = [Employee]()
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        for source in sources {
            let fetched = try await urlSession.data(from: source)
            let decoded = try decoder.decode(EmployeesResponse.self, from: fetched.0)
            result.append(contentsOf: decoded.employees)
        }
        return result
    }
}
