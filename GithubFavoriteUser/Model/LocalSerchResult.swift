//
//  LocalSerchResult.swift
//  GithubFavoriteUser
//
//  Created by JihoonKim on 2022/04/20.
//

import Foundation
import RealmSwift

class LocalSerchUserInfo: Object {
    @Persisted(primaryKey: true) var userId: Int64
    @Persisted var userName: String = ""
    @Persisted var profileImg: String = ""
    
    convenience init(userId: Int64) {
        self.init()
        self.userId = userId
    }
}
