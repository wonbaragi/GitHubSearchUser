//
//  SearchUserRequest.swift
//  GithubFavoriteUser
//
//  Created by JihoonKim on 2022/04/18.
//

import Foundation
import Moya

enum SearchUserRequest {
    case getSearchUserResult(keyword : String)
}

extension SearchUserRequest: TargetType {
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
    
    var method: Moya.Method {
        switch self {
        case .getSearchUserResult:
            return .get
        }
    }

    var path: String {
        switch self {
            case .getSearchUserResult(let keyword):
                return "/search/users/p=\(keyword)"
        }
    }
}
