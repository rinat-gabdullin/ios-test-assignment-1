//
//  CacheStub.swift
//  MoonCascadeTestTests
//
//  Created by Rinat Gabdullin on 14.04.2022.
//

import XCTest
@testable import MoonCascadeTest

class CacheStub: Cache {
    var dictionary = [String: Any]()
    
    func read<T>(key: String) -> T? where T : Decodable, T : Encodable {
        return dictionary[key] as? T
    }
    
    func save<T>(data: T, key: String) where T : Decodable, T : Encodable { dictionary[key] = data }
}

