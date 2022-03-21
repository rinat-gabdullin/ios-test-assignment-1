//
//  EmployeeDetailsViewController.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 21.03.2022.
//

import Foundation
import UIKit

struct EmployeeDetailsViewModel {
    var title: String
    var name: String
    var projects: String?
    var phone: String?
    var mail: String
    
    var openContactAction: UIAction?
}

final class EmployeeDetailsViewController: UIViewController {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var projectsLabel: UILabel!
    @IBOutlet private var contactButton: UIButton!
    
    var model: EmployeeDetailsViewModel?
    
    private func configure(with model: EmployeeDetailsViewModel) {
        titleLabel.text = model.title
        nameLabel.text = model.name
        
        projectsLabel.text = model.projects
        projectsLabel.isHidden = model.projects == nil
        
        contactButton.configuration?.title = model.phone
        contactButton.configuration?.subtitle = model.mail
        
        if let action = model.openContactAction {
            contactButton.addAction(action, for: .touchUpInside)
        } else {
            contactButton.isEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let model = model {
            configure(with: model)
        } else {
            assertionFailure("No model")
        }
    }
}
