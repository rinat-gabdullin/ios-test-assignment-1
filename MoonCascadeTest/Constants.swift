//
//  Constants.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 13.03.2022.
//

import Foundation

enum Constant {
    static let dataSources = [
        // These endpoints change their data every minute
        URL(string: "https://tallinn-jobapp.aw.ee/employee_list")!,
        URL(string: "https://tartu-jobapp.aw.ee/employee_list")!
    ]
}
