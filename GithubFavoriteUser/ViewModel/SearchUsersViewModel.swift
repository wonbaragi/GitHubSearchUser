//
//  SearchUsersViewModel.swift
//  GithubFavoriteUser
//
//  Created by JihoonKim on 2022/04/19.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RealmSwift

enum ViewModelState {
    case success
    case failure
}

class SearchUsersViewModel: NSObject {
    
    private let localFavoriteRealm = try! Realm()
    
    private let githubFavoriteUserService: GithubFavoriteUserService
    private let disposeBag = DisposeBag()
    
    var users = BehaviorRelay<[SearchUserInfo]>(value: [])
    var favoriteUsers = BehaviorRelay<[LocalSerchUserInfo]>(value: [])
    private var pageNumber = 1
    
    init(_ githubFavoriteUserService: GithubFavoriteUserService) {
        self.githubFavoriteUserService = githubFavoriteUserService
    }
    
    func clearUserData() {
        if !users.value.isEmpty {
            users.accept([])
        }
        pageNumber = 1
    }
    
    func getSearchUsers(keyword: String, pageNum: Int = 1) {
        if pageNum == 1 {
            clearUserData()
        }
        
        print("pageNum \(pageNum)")
        
        GithubFavoriteUserService()
            .searchUsers(with: keyword, page: pageNum)
            .compactMap { $0 }
            .subscribe(onNext: { searchUsers in
                if pageNum == 1 {
                    self.users.accept(searchUsers)
                }
                else {
                    self.users.accept(self.users.value + searchUsers)
                }
            }).disposed(by: self.disposeBag)
    }
    
    func getNextPageSearchUser(keyword: String) {
        pageNumber += 1
        getSearchUsers(keyword: keyword, pageNum: pageNumber)
    }
    
    func getLocalUsers() {
        if !favoriteUsers.value.isEmpty {
            favoriteUsers.accept([])
        }
        let getList = localFavoriteRealm.objects(LocalSerchUserInfo.self)
            .sorted(byKeyPath: "userName", ascending: true)
        
        if getList.count > 0 {
            for item in getList {
                print("item \(item.userName)")
            }
            favoriteUsers.accept(Array(getList))
        }
    }
    
    func updateLocalUsersFavorite(_ user : SearchUserInfo) {
        try! localFavoriteRealm.write {
            if let findUser = localFavoriteRealm.object(ofType: LocalSerchUserInfo.self, forPrimaryKey: user.userId) {
                localFavoriteRealm.delete(localFavoriteRealm.object(ofType: LocalSerchUserInfo.self, forPrimaryKey: findUser.userId)!)
                user.isFavorite = false
            }
            else {
                let favoriteUesr = LocalSerchUserInfo(userId: user.userId)
                favoriteUesr.userName = user.userName
                favoriteUesr.profileImg = user.profileImg
                user.isFavorite = true
                localFavoriteRealm.add(favoriteUesr, update: .modified)
            }

//            if !favoriteUesr.isFavorite {
//                localFavoriteRealm.add(favoriteUesr, update: .modified)
//                self.users.value[index].isFavorite = true
//            }
//            else {
//                localFavoriteRealm.delete(localFavoriteRealm.object(ofType: LocalSerchUserInfo.self, forPrimaryKey: favoriteUesr.userId)!)
//                self.users.value[index].isFavorite = false
//            }
        }
    }
    
    func deleteLocalUserFavorite(_ userID: Int64, completion: @escaping () -> Void ) {
        try! localFavoriteRealm.write {
            if let favoriteUesr = localFavoriteRealm.object(ofType: LocalSerchUserInfo.self, forPrimaryKey: userID) {
                print("favoriteUesr delete \(favoriteUesr.userName)")
                if localFavoriteRealm.object(ofType: LocalSerchUserInfo.self, forPrimaryKey: favoriteUesr.userId) != nil {
                    localFavoriteRealm.delete(localFavoriteRealm.object(ofType: LocalSerchUserInfo.self, forPrimaryKey: favoriteUesr.userId)!)
                    getLocalUsers()
                    completion()
                }
            }
        }
    }
}
