//
//  Stirng+Extention.swift
//  GithubFavoriteUser
//
//  Created by JihoonKim on 2022/04/21.
//

import Foundation

extension String {
    func initialConsonant() -> String? {
        guard let firstWord = self.first else { return nil }
        guard let consonant = String(firstWord).decomposedStringWithCompatibilityMapping.unicodeScalars.first else { return nil }
        return UnicodeScalar(consonant).description
    }
}
