//
//  ProjectViewModel.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 02.05.2022.
//

import Foundation

struct ProjectViewModel: Identifiable {
    var id: String
    var title: String
    var details: [ProjectDetailsViewModel]
}

struct ProjectDetailsViewModel: Identifiable {
    var id: String
    var imageName: String
    var position: String
    var count: Int
    
    static func random() -> ProjectDetailsViewModel {
        let position = EmployeePosition.allCases.randomElement()!
        return ProjectDetailsViewModel(id: UUID().uuidString,
                                       imageName: position.imageName,
                                       position: position.title,
                                       count: (1...100).randomElement()!)
    }
}

extension EmployeePosition {
    var imageName: String {
        switch self {
        case .ios:
            return "applelogo"
        case .android:
            return "platter.filled.top.applewatch.case"
        case .web:
            return "safari.fill"
        case .pm:
            return "digitalcrown.horizontal.arrow.counterclockwise.fill"
        case .tester:
            return "checkmark.seal.fill"
        case .sales:
            return "dollarsign.square.fill"
        case .other:
            return "person.circle.fill"
        }
    }
}
