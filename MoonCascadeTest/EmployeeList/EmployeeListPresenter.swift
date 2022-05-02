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
    
    @Published var searchString = ""
    
    private let provider: EmployeeProvider
    
    private var subscriptions = [AnyCancellable]()
    
    internal init(provider: EmployeeProvider) {
        self.provider = provider
    }

    /// Reloads data from cache and network
    /// - Returns: Data stream of EmployeesTable
    func startSendingData() -> AnyPublisher<EmployeesTable, Never> {
        
        Task {
            await provider.reloadData()
        }
        
        return updatesFlow()
    }
    
    func reloadData() async {
        await provider.reloadData()
    }
    
    func errorsPublisher() -> AnyPublisher<String, Never> {
        provider.$lastError.eraseToAnyPublisher()
    }
    
    private func updatesFlow() -> AnyPublisher<EmployeesTable, Never> {
        $searchString
            .map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
            .combineLatest(provider.$allEmployees)
        
            // Filtering by search string
            .map { (searchString, allEmployees) -> [EnumeratedSequence<[Employee]>.Element] in
                let enumerated = allEmployees.enumerated()
                
                if searchString.isEmpty {
                    return enumerated.filter { _ in true } // no idea why `filter` is required
                }
                
                return enumerated.filter { $0.element.searchString.contains(searchString) }
            }
        
            // Converting to ListViewModel and grouping them by positions
            .map { filteredEmployees -> EmployeesByPosition in
                let new = EmployeesByPosition()
                
                return filteredEmployees
                    .sorted(by: { $0.element.lname < $1.element.lname })
                    .reduce(new) { partialResult, item in
                        let employee = item.element
                        var result = partialResult
                        let viewModel = ListViewModel(name: employee.fullName, index: item.offset)
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
    
    func detailsViewModel(atIndex index: Int) -> EmployeeDetailsViewModel? {
        let model = provider.allEmployees[index]
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
