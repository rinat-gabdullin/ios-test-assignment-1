//
//  DataSource.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 13.03.2022.
//

import UIKit

class DataSource: UITableViewDiffableDataSource<EmployeePosition, EmployeeListManager.ViewModel> {
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        
        return sectionIdentifier(for: section)?.title
    }
}
