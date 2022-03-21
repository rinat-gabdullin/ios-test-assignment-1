//
//  Assembly.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 13.03.2022.
//

import Foundation

class EmployeeListAssembly {
    func make() -> EmployeeListManager {
        let urlSession = URLSession.shared
        let cache = try? FileCache()
        assert(cache != nil)
        let service = EmployeesService(urlSession: urlSession, sources: Constant.dataSources)
        let provider = EmployeesProvider(service: service, cache: cache)
        let manager = EmployeeListManager(provider: provider)
        return manager
    }
}
