//
//  Extensions.swift
//  InSpace
//
//  Created by Andy Copsey on 03/01/2025.
//

import Foundation
import UIKit

/// High level extensions for existing classes
extension NSAttributedString {
    
    /// Returns a new NSMutableAttributedString with the specified styling properties
    public static func new(_ text: String, font: UIFont, color: UIColor) -> NSAttributedString {
        
        // set up attributes for this new attributed string
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        
        // return this new string
        return NSMutableAttributedString(string: text, attributes: attributes)
    }
    
    /// Convenience method for building a bold string
    public static func bold(_ text: String, color: UIColor, size: CGFloat) -> NSAttributedString {
        let font = UIFont.boldSystemFont(ofSize: size)
        return new(text, font: font, color: color)
    }
    
    /// Convenience method for building a regular string
    public static func regular(_ text: String, color: UIColor, size: CGFloat) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: size)
        return new(text, font: font, color: color)
    }
}

extension UIAlertController {
    
    /// Convenience wrapper to show a basic alert view
    static func show(parent: UIViewController, title: String, message: String) {
        DispatchQueue.main.async {
            let avc = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            avc.addAction(action)
            parent.present(avc, animated: true)
        }
    }
}

extension UIViewController {
    
    /// Adds this view controller's view into the specified parent view, pinning all sides
    /// to their respective anchor points
    func injectView(into parentController: UIViewController, animated: Bool = false) {
        
        // add this view controller to the parent
        parentController.addChild(self)
        
        // prepare and add the view
        view.alpha = animated ? 0 : 1
        view.translatesAutoresizingMaskIntoConstraints = false
        parentController.view.addSubview(view)
        
        // set up constraints
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: parentController.view.leftAnchor),
            view.rightAnchor.constraint(equalTo: parentController.view.rightAnchor),
            view.topAnchor.constraint(equalTo: parentController.view.topAnchor),
            view.bottomAnchor.constraint(equalTo: parentController.view.bottomAnchor)
        ])
        
        // animation
        if animated {
            UIView.animate(withDuration: 0.8) {
                self.view.alpha = 1
            }
        }
    }
    
}
