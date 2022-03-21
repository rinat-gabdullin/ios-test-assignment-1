//
//  UIAction+Extensions.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 21.03.2022.
//

import UIKit
import ContactsUI

extension UIAction {
    static func forContact(_ contact: CNContact) -> UIAction {
        UIAction { action in
            let contactViewController = CNContactViewController(for: contact)
            
            guard
                let responder = action.sender as? UIResponder,
                let viewController = responder.firstResponder(of: UIViewController.self)
            else {
                return
            }
            
            let closeAction = UIAction { _ in
                contactViewController.dismiss(animated: true)
            }
            
            let closeItem = UIBarButtonItem(systemItem: .close, primaryAction: closeAction, menu: nil)
            contactViewController.navigationItem.leftBarButtonItem = closeItem
            
            let navigationController = UINavigationController(rootViewController: contactViewController)
            viewController.present(navigationController, animated: true)
        }
    }
}
