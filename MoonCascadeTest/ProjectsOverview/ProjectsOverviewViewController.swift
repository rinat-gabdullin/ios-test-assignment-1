//
//  ProjectsOverviewViewController.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 02.05.2022.
//

import UIKit
import SwiftUI

final class ProjectsOverviewViewController: UIViewController {
    
    let presenter: ProjectsOverviewPresenter
    
    required init?(coder: NSCoder) {
        presenter = ApplicationAssembly.shared.makePresenter()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let contentView = ProjectsOverviewView(updatesPublisher: presenter.updatesFlow())
        let viewController = UIHostingController(rootView: contentView)
        viewController.willMove(toParent: self)
        self.addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.frame = view.bounds
    }
}
