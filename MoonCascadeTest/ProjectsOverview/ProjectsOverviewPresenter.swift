//
//  ProjectsOverview.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 02.05.2022.
//

import Foundation
import Combine

final class ProjectsOverviewPresenter {
    
    private let provider: EmployeeProvider
    
    internal init(provider: EmployeeProvider) {
        self.provider = provider
    }
    
    func updatesFlow() -> AnyPublisher<[ProjectViewModel], Never> {
        provider
            .$allEmployees
        
            // Dictionary representation of view data
            .map { employees -> [EmployeeProject: [EmployeePosition: Int]] in
                
                var result = [EmployeeProject: [EmployeePosition: Int]]()
                
                for employee in employees {
                    guard let projects = employee.projects else { continue }
                    for project in projects {
                        result[project, default: [:]][employee.position, default: 0] += 1
                    }
                }
                
                return result
            }
            .map(Self.makeViewModels(data:))
            .eraseToAnyPublisher()
    }
    
    /// Mapping dictionary representation to view model
    private static func makeViewModels(data: [EmployeeProject: [EmployeePosition: Int]]) -> [ProjectViewModel] {
        
        var viewModels = [ProjectViewModel]()
        for project in data.keys.sorted(by: { $0.identifier > $1.identifier }) {
            
            guard let contents = data[project] else {
                continue
            }
            
            let details = contents
                .sorted(by: { $0.key.sortingIndex < $1.key.sortingIndex })
                .map { (position, count) in
                    ProjectDetailsViewModel(id: project.identifier + position.rawValue,
                                            imageName: position.imageName,
                                            position: position.title,
                                            count: count)
                }
            
            let model = ProjectViewModel(id: project.identifier,
                                         title: project.identifier,
                                         details: details)
            
            viewModels.append(model)
        }
        return viewModels
    }
}
