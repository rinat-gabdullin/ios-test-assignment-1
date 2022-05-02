//
//  ListViewModel.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 12.04.2022.
//

import Foundation

struct ListViewModel: Identifiable, Hashable {
    var name: String
    var id: String { name }
    var index: Int
}

typealias EmployeesByPosition = [EmployeePosition: [ListViewModel]]

struct EmployeesTable {
    var employeesByPosition = EmployeesByPosition()
}
