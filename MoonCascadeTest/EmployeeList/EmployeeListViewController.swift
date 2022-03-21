//
//  ViewController.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 11.03.2022.
//

import UIKit
import Combine
import ContactsUI

class EmployeeListViewController: UITableViewController, UISearchBarDelegate {

    private var subsriptions = [AnyCancellable]()

    let employeeListManager: EmployeeListManager
    
    required init?(coder: NSCoder) {
        employeeListManager = EmployeeListAssembly().make()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        employeeListManager.startDisplaying(with: tableView)
        tableView.sectionHeaderHeight = 44
        
        employeeListManager.$lastError
            .filter { !$0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showAlert(text: error)
            }
            .store(in: &subsriptions)
        
        CNContactStore().requestAccess(for: .contacts) { _, _ in
            
        }
    }

    @IBAction private func refresh(sender: UIRefreshControl) {
        Task {
            await employeeListManager.reloadData()
            DispatchQueue.main.async {
                sender.endRefreshing()                
            }
        }
    }
    
    private func showAlert(text: String) {
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        employeeListManager.searchString = searchText
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard
            segue.identifier == "Detail",
            let indexPath = tableView.indexPathForSelectedRow,
            let destinationViewController = segue.destination as? EmployeeDetailsViewController,
            let detailsViewModel = employeeListManager.detailsViewModel(for: indexPath)
        else {
            assertionFailure("Unexpected segue")
            return
        }
        
        destinationViewController.model = detailsViewModel
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let controller = segue.destination.sheetPresentationController {
            controller.detents = [.medium(), .large()]
            controller.prefersGrabberVisible = true
        } else {
            assertionFailure("Unexpected segue")
        }
        
    }
}

