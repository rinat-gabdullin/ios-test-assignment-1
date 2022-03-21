//
//  Project.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 13.03.2022.
//

import Foundation

struct EmployeeProject: Codable, Equatable, Hashable {
    var identifier: String
    
    init(from decoder: Decoder) throws {
        identifier = try decoder.singleValueContainer().decode(String.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(identifier)
    }
}
