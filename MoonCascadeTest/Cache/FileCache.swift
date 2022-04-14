//
//  Cache.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 13.03.2022.
//

import Foundation

protocol Cache {
    func save<T: Codable>(data: T, key: String)
    func read<T: Codable>(key: String) -> T?
}

class FileCache: Cache {
    
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    let directoryURL: URL

    private let queue = DispatchQueue(label: "file-cache.test", attributes: .concurrent)
    
    init() throws {
        encoder.keyEncodingStrategy = .convertToSnakeCase
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let directoryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Cache", isDirectory: true)
        
        self.directoryURL = directoryURL
        
        if !fileManager.fileExists(atPath: directoryURL.absoluteString) {
            try fileManager.createDirectory(at: directoryURL,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
        }
    }
    
    func save<T>(data: T, key: String) where T: Codable {
        queue.async(flags: .barrier) {
            if let encodedData = try? self.encoder.encode(data.self) {
                let url = self.url(forKey: key)
                try? encodedData.write(to: url)
            }
        }
    }
    
    func read<T>(key: String) -> T? where T: Codable {
        var result: T?
        
        queue.sync {
            let url = self.url(forKey: key)
            if let data = try? Data(contentsOf: url) {
                result = try? decoder.decode(T.self, from: data)
            }
        }
        
        return result
    }
    
    private func url(forKey key: String) -> URL {
        directoryURL.appendingPathComponent("\(key).data", isDirectory: false)
    }
}
