//
//  EmployeeListManager.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 13.03.2022.
//

import Foundation
import UIKit
import Combine
import ContactsUI

class EmployeeListManager {

    struct ViewModel: Identifiable, Hashable {
        var name: String
        var id: String { name }
        var index: Int
    }
    
    @Published var searchString = ""
    @Published private(set) var lastError: String = ""
    @Published private var allEmployees = [Employee]()
    @Published private var displayedViewModels = [EmployeePosition: [ViewModel]]()
    
    private let provider: EmployeesProvider
    private var dataSource: DataSource?
    private var subsriptions = [AnyCancellable]()
    
    init(provider: EmployeesProvider) {
        
        self.provider = provider
        
        let searchSignal = $searchString
            .map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
        
        searchSignal.combineLatest($allEmployees)
            .map { (searchString, allEmployees) in
                if searchString.isEmpty {
                    return allEmployees
                }
                return allEmployees.filter { $0.searchString.contains(searchString) }
            }
            .sink { [weak self] models in
                self?.updateViewModels(models: models)
                
            }
            .store(in: &subsriptions)
        
    }
    
    func reloadData() async {
        do {
            let fetched = try await provider.fetch()
            allEmployees = fetched
        } catch {
            lastError = error.localizedDescription
        }
    }
    
    func startDisplaying(with tableView: UITableView) {
        
        assert(dataSource == nil)
        
        let dataSource = DataSource(tableView: tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = itemIdentifier.name
            return cell
        }
        
        dataSource.defaultRowAnimation = .top
        self.dataSource = dataSource
        tableView.dataSource = dataSource
        
        allEmployees = provider.loadFromCache()
        
        Task {
            await reloadData()
        }
    }
    
    func detailsViewModel(for indexPath: IndexPath) -> EmployeeDetailsViewModel? {
        guard
            let viewModel = dataSource?.itemIdentifier(for: indexPath)
        else {
            return nil
        }
        
        let model = allEmployees[viewModel.index]
        return makeDetailsViewModel(model: model)
    }
    
    private func updateView(animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<EmployeePosition, ViewModel>()
        let sections = EmployeePosition.allCases
        for section in sections {
            guard
                let items = displayedViewModels[section],
                !items.isEmpty
            else {
                continue
            }
            
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
        }
        
        DispatchQueue.main.async {
            self.dataSource?.apply(snapshot, animatingDifferences: animated)
        }

    }
    
    private func updateViewModels(models: [Employee]) {
        let new = [EmployeePosition: [ViewModel]]()
        
        displayedViewModels = models.indices
            .map { (index: $0, model: models[$0]) }
            .sorted(by: { $0.model.lname < $1.model.lname })
            .reduce(new) { partialResult, tuple in
                let employee = tuple.model
                var result = partialResult
                let viewModel = makeListViewModel(model: employee, index: tuple.index)
                result[employee.position, default: []].append(viewModel)
                return result
            }
        
        updateView(animated: true)
    }
    
    private func makeListViewModel(model: Employee, index: Int) -> ViewModel {
        ViewModel(name: model.fullName, index: index)
    }
    
    private func makeDetailsViewModel(model: Employee) -> EmployeeDetailsViewModel {
        EmployeeDetailsViewModel(title: model.position.title,
                                 name: model.fullName,
                                 projects: model.projects.map { $0.map { $0.identifier }.joined(separator: " | ") },
                                 phone: model.contactDetails.phone,
                                 mail: model.contactDetails.email,
                                 openContactAction: openContactAction(for: model))
    }
    
    private func openContactAction(for model: Employee) -> UIAction? {
        
        let predicate = CNContact.predicateForContacts(matchingName: model.fullName)
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
