//
//  EmployeePosition.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 13.03.2022.
//

import Foundation

enum EmployeePosition: String, Codable, CaseIterable, Equatable, Hashable {
    case ios = "IOS"
    case android = "ANDROID"
    case web = "WEB"
    case pm = "PM"
    case tester = "TESTER"
    case sales = "SALES"
    case other = "OTHER"
    
    init(from decoder: Decoder) throws {
        let stringValue = try decoder.singleValueContainer().decode(String.self)
        let decodedValue = Self(rawValue: stringValue)
        assert(decodedValue != nil)
        self = decodedValue ?? .other
    }
    
    var title: String {
        switch self {
        case .ios:
            return "iOS developer"
            
        case .android:
            return "Android developer"
            
        case .web:
            return "Front-end developer"
            
        case .pm:
            return "Project manager"
            
        case .tester:
            return "QA Engineer"
            
        case .sales:
            return "Sales"
            
        case .other:
            return "Other"
        }
    }
}
