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
            favoriteUsers.accept(Array(getList))
        }
    }
    
    func updateLocalUsersFavorite(_ index : Int) {
        try! localFavoriteRealm.write {
            let favoriteUesr = LocalSerchUserInfo(userId: self.users.value[index].userId)
            favoriteUesr.userName = self.users.value[index].userName
            favoriteUesr.profileImg = self.users.value[index].profileImg
            
            if !self.users.value[index].isFavorite {
                localFavoriteRealm.add(favoriteUesr, update: .modified)
                self.users.value[index].isFavorite = true
            }
            else {
                localFavoriteRealm.delete(localFavoriteRealm.object(ofType: LocalSerchUserInfo.self, forPrimaryKey: favoriteUesr.userId)!)
                self.users.value[index].isFavorite = false
            }
        }
    }
    
    func deleteLocalUserFavorite(_ index: Int) {
        try! localFavoriteRealm.write {
            let favoriteUesr = LocalSerchUserInfo(userId: self.favoriteUsers.value[index].userId)
            if localFavoriteRealm.object(ofType: LocalSerchUserInfo.self, forPrimaryKey: favoriteUesr.userId) != nil {
                localFavoriteRealm.delete(localFavoriteRealm.object(ofType: LocalSerchUserInfo.self, forPrimaryKey: favoriteUesr.userId)!)
                getLocalUsers()
            }
            
        }
    }
}
