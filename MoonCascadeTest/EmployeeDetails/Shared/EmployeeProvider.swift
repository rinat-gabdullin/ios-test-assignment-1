//
//  EmployeeProvider.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 02.05.2022.
//

import Foundation
import Combine

final class EmployeeProvider {
    
    let cacheKey = "employees"
    
    private let service: IEmployeesService
    private let cache: Cache?
    
    @Published private(set) var allEmployees = [Employee]()
    @Published private(set) var lastError: String = ""
    
    internal init(service: IEmployeesService, cache: Cache?) {
        self.service = service
        self.cache = cache
        
        allEmployees = loadFromCache()
    }
    
    private func loadFromCache() -> [Employee] {
        cache?.read(key: cacheKey) ?? []
    }
    
    private func saveToCache(employees: [Employee]) {
        cache?.save(data: employees, key: cacheKey)
    }
    
    // Reloads data from network
    func reloadData() async {
        do {
            let fetched = try await fetch()
            allEmployees = fetched
        } catch {
            lastError = error.localizedDescription
        }
    }
    
    private func fetch() async throws -> [Employee] {
        let result = try await service.fetchAll()
        saveToCache(employees: result)
        return result
    }
}
