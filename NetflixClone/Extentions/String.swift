//
//  String.swift
//  NetflixClone
//
//  Created by Assem on 21/09/2022.
//

import Foundation

extension String {
    func capitalizeFirstLetter() -> String {
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}
