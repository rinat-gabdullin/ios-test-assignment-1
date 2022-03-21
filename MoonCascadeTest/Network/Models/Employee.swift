//
//  Employee.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 13.03.2022.
//

import Foundation

struct Employee: Codable, Equatable, Hashable {
    let fname: String
    let lname: String
    let contactDetails: EmployeeContacts
    let position: EmployeePosition
    let projects: [EmployeeProject]?
    
    var searchString: String {
        // TODO: caching
        
        var item = [fname, lname, contactDetails.email, position.rawValue, position.title]
        if let projects = projects {
            item.append(contentsOf: projects.map { $0.identifier })
        }
        return item.joined(separator: "").lowercased()
    }
    
    var fullName: String { "\(fname) \(lname)" }
}
