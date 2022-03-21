//
//  UIResponder+Extensions.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 21.03.2022.
//

import UIKit

extension UIResponder {
    func firstResponder<T>(of type: T.Type) -> T? {
        var responder: UIResponder? = self
        while let unwrapped = responder {
            if let result = unwrapped as? T {
                return result
            } else {
                responder = unwrapped.next
            }
        }
        
        return nil
    }
}
