//
//  UIViewController.swift
//  NetflixClone
//
//  Created by Assem on 23/09/2022.
//

import UIKit

extension UIViewController {

    public func showAlertmessage(with message: String, title: String? = nil) {

        let alert = UIAlertController(title: title ?? "Error", message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default) { _ in

        }
        alert.view.tintColor = .white
        alert.addAction(dismissAction)
        self.present(alert, animated: true)
    }

}
