//
//  Assembly.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 13.03.2022.
//

import Foundation

class EmployeeListAssembly {
    func make() -> EmployeeListPresenter {
        let urlSession = URLSession.shared
        let cache = try? FileCache()
        assert(cache != nil)
        let service = EmployeesService(urlSession: urlSession, sources: Constant.dataSources)
        let manager = EmployeeListPresenter(service: service, cache: cache)
        return manager
    }
}
