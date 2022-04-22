//
//  UnicodeUtil.swift
//  GithubFavoriteUser
//
//  Created by JihoonKim on 2022/04/21.
//

import Foundation

enum UnicodeUtil {
    
    static let NUMBER_CONSONANTS = Array(0x0031...0x0039)
    static let KOREAN_CONSONANTS = Array(0x1100...0x1112)
    static let KOREAN_DOUBLE_CONSONANTS = [0x1101, 0x1104, 0x1108, 0x110A, 0x110D]
    
    static let ALPHABET = Array(0x0041...0x5A)
    
    static let UNICODE_DICTIONARY = (NUMBER_CONSONANTS + KOREAN_CONSONANTS + ALPHABET)
        .filter { !KOREAN_DOUBLE_CONSONANTS.contains($0) }
        .compactMap { UnicodeScalar($0) }
        .map { "\(Character($0))" }
        .reduce(into: [String: [LocalSerchUserInfo]]()) { $0[$1] = [LocalSerchUserInfo]() }
}
