//
//  SearchResult.swift
//  GithubFavoriteUser
//
//  Created by JihoonKim on 2022/04/18.
//

import Foundation
import ObjectMapper

class SearchUserInfo: Mappable {
    
    var userId: Int64 = -1
    var profileImg: String = ""
    var userName: String = ""
    var isFavorite: Bool = false
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        userId <- map["id"] // 해당 값으로 즐겨찾기 여부 확인
        profileImg <- map["avatar_url"]
        userName <- map["login"]
    }
}
