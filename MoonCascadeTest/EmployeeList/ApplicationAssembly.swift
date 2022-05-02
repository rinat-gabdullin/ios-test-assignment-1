//
//  Assembly.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 13.03.2022.
//

import Foundation

class ApplicationAssembly {
    static let shared = ApplicationAssembly()

    private let urlSession = URLSession.shared
    private let provider: EmployeeProvider
    
    init() {
        let cache = try? FileCache()
        assert(cache != nil)
        
        let service = EmployeesService(urlSession: urlSession, sources: Constant.dataSources)
        provider = EmployeeProvider(service: service, cache: cache)
    }
    
    func makePresenter() -> EmployeeListPresenter {
        EmployeeListPresenter(provider: provider)
    }
    
    func makePresenter() -> ProjectsOverviewPresenter {
        ProjectsOverviewPresenter(provider: provider)
    }
}
