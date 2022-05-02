//
//  EmployeeListProvider.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 12.04.2022.
//

import Foundation
import UIKit
import Combine

final class EmployeeTableViewUpdater {
    
    private let dataSource: DataSource
    private var tableData = EmployeesTable()
    private var subscriptions = [AnyCancellable]()

    init(tableView: UITableView, updates: AnyPublisher<EmployeesTable, Never>) {
    
        dataSource = DataSource(tableView: tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = itemIdentifier.name
            return cell
        }
        
        dataSource.defaultRowAnimation = .top
        tableView.dataSource = dataSource
        
        updates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newData in
                self?.tableData = newData
                self?.updateView()
            }
            .store(in: &subscriptions)
    }
    
    private func updateView() {
        var snapshot = NSDiffableDataSourceSnapshot<EmployeePosition, ListViewModel>()
        let sections = EmployeePosition.allCases
        for section in sections {
            guard
                let items = tableData.employeesByPosition[section],
                !items.isEmpty
            else {
                continue
            }
            
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
        }
        
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    public func index(for indexPath: IndexPath) -> Int? {
        dataSource.itemIdentifier(for: indexPath)?.index
    }
}
