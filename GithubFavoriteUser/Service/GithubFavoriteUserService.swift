//
//  GithubFavoriteUserService.swift
//  GithubFavoriteUser
//
//  Created by JihoonKim on 2022/04/18.
//

import RxSwift
import Alamofire
import SwiftyJSON
import ObjectMapper

class GithubFavoriteUserService {
     private let baseURL = "https://api.github.com"
     
     func searchUsers(with keyword: String, page: Int) -> Observable<[SearchUserInfo]?> {
          let url = baseURL + "/search/users"
          let params: Parameters = ["q": keyword, "page": page]
          let headers: HTTPHeaders = ["accept": "application/vnd.github.v3+json"]
          
          return .create() { subscriber in
               guard
                    let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
               else {
                    return Disposables.create()
               }
               
               AF.request(encodedURL, method: .get, parameters: params, headers: headers)
                    .responseData { response in
                         switch response.result {
                         case .success(let data):
                              let json = JSON(data)
                              let items = json["items"].arrayObject
                              let usersInfo = Mapper<SearchUserInfo>().mapArray(JSONObject: items)
                              subscriber.onNext(usersInfo)
                         case .failure(let error):
                              subscriber.onError(error)
                         }
                    }
               return Disposables.create()
          }
     }
}
