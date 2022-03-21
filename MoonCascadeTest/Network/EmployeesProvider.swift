//
//  EmployeesProvider.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 13.03.2022.
//

import Foundation

class EmployeesProvider {
    let service: EmployeesService
    let cache: Cache?
    
    internal init(service: EmployeesService, cache: Cache?) {
        self.service = service
        self.cache = cache
    }
    
    func fetch() async throws -> [Employee] {
        var result = try await service.fetchAll()
        result = Array(Set(result))
        saveToCache(employees: result)
        return result
    }
    
    func loadFromCache() -> [Employee] {
        cache?.read(key: "employees") ?? []
    }
    
    private func saveToCache(employees: [Employee]) {
        cache?.save(data: employees, key: "employees")
    }
}
