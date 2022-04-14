//
//  EmployeeListPresenter.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 13.03.2022.
//

import Foundation
import UIKit
import Combine
import ContactsUI

final class EmployeeListPresenter {

    let cacheKey = "employees"
    
    @Published var searchString = ""
    @Published private(set) var lastError: String = ""
    @Published private var allEmployees = [Employee]()
    
    private var subscriptions = [AnyCancellable]()
    private let service: IEmployeesService
    private let cache: Cache?

    internal init(service: IEmployeesService, cache: Cache?) {
        self.service = service
        self.cache = cache
    }
    
    /// Reloads data from cache and network
    /// - Returns: Data stream of EmployeesTable
    func startSendingData() -> AnyPublisher<EmployeesTable, Never> {
        allEmployees = loadFromCache()

        Task {
            await reloadData()
        }
        
        return updatesFlow()
    }
    
    // Reloads data from network
    func reloadData() async {
        do {
            let fetched = try await fetch()
            allEmployees = fetched
        } catch {
            lastError = error.localizedDescription
        }
    }
    
    private func updatesFlow() -> AnyPublisher<EmployeesTable, Never> {
        $searchString
            .map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
            .combineLatest($allEmployees)

            // Filtering by search string
            .map { (searchString, allEmployees) -> [Employee] in
                if searchString.isEmpty {
                    return allEmployees
                }
                return allEmployees.filter { $0.searchString.contains(searchString) }
            }
        
            // Converting to ListViewModel and grouping them by positions
            .map { filteredEmployees -> EmployeesByPosition in
                let new = EmployeesByPosition()
                return filteredEmployees
                    .indices
                    .map { (index: $0, model: filteredEmployees[$0]) }
                    .sorted(by: { $0.model.lname < $1.model.lname })
                    .reduce(new) { partialResult, tuple in
                        let employee = tuple.model
                        var result = partialResult
                        let viewModel = ListViewModel(name: employee.fullName, index: tuple.index)
                        result[employee.position, default: []].append(viewModel)
                        return result
                    }
            }
        
            // Wrapping to EmployeesTable
            .map { EmployeesTable(employeesByPosition: $0) }
        
            // Do everything above in background
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
        
            .eraseToAnyPublisher()
    }

    private func fetch() async throws -> [Employee] {
        let result = try await service.fetchAll()
        saveToCache(employees: result)
        return result
    }
    
    private func loadFromCache() -> [Employee] {
        cache?.read(key: cacheKey) ?? []
    }
    
    private func saveToCache(employees: [Employee]) {
        cache?.save(data: employees, key: cacheKey)
    }
    
    func detailsViewModel(atIndex index: Int) -> EmployeeDetailsViewModel? {
        let model = allEmployees[index]
        return model.makeDetailsViewModel()
    }
}

extension Employee {
    func makeDetailsViewModel() -> EmployeeDetailsViewModel {
        EmployeeDetailsViewModel(title: position.title,
                                 name: fullName,
                                 projects: projects.map { $0.map { $0.identifier }.joined(separator: " | ") },
                                 phone: contactDetails.phone,
                                 mail: contactDetails.email,
                                 openContactAction: openContactAction())
    }
    
    private func openContactAction() -> UIAction? {
        
        let predicate = CNContact.predicateForContacts(matchingName: fullName)
        let store = CNContactStore()
        let keysToFetch = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactViewController.descriptorForRequiredKeys()]
        
        let contacts = try? store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
        
        guard let contact = contacts?.first else {
            return nil
        }
        
        return UIAction.forContact(contact)
    }

}
