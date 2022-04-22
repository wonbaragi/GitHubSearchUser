//
//  FavoriteUserTableViewDataSource.swift
//  GithubFavoriteUser
//
//  Created by JihoonKim on 2022/04/21.
//

import Foundation
import UIKit
import RxSwift
import RealmSwift

class FavoriteUserTableViewDataSource: NSObject, UITableViewDataSource {
    
    typealias UserSection = (key: String, value: [LocalSerchUserInfo])
    private let localFavoriteRealm = try! Realm()
    
    public var viewModel: SearchUsersViewModel?
    private let disposeBag = DisposeBag()
    
    var searchText: String = "" {
        didSet {
            filteredSections = searchText.isEmpty ? favoriteUserSections : makeFilteredSection()
        }
    }
    
    private var favoriteUser: [LocalSerchUserInfo] = []
    private var favoriteUserSections: [UserSection] = [] {
        didSet {
            filteredSections = favoriteUserSections
            dataDidUpdated?()
        }
    }
    private var filteredSections: [UserSection] = [] {
        didSet {
            dataDidUpdated?()
        }
    }
    private var searchedConsonants: [String] {
        return searchText.compactMap { String($0).initialConsonant() }
    }
    
    
    // MARK: - Closures
    
    var dataDidUpdated: (() -> Void)?
    
    func showFavoriteUserList() {
        var consonents = UnicodeUtil.UNICODE_DICTIONARY
        favoriteUser.removeAll()
        
        favoriteUser = Array(localFavoriteRealm.objects(LocalSerchUserInfo.self)
            .sorted(byKeyPath: "userName", ascending: true))
        
        Observable.from(favoriteUser)
            .subscribe(onNext: {
                if let consonant = $0.userName.initialConsonant()?.uppercased() {
                    consonents[consonant]?.append($0)
                }
            }, onCompleted: {
                self.favoriteUserSections = consonents.sorted { $0.key < $1.key }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - UITableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSections[section].value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchUsersCell", for: indexPath) as? SearchUsersTableViewCell else {
            return .init()
        }
        let section = filteredSections[indexPath.section]
        let favoriteUser = section.value[indexPath.row]
        cell.bindCell(favoriteUser, cellType: .LOCAL)
        
        cell.btnSetFavorite.rx.tap.bind { [weak self] in
            if let viewmodel = self?.viewModel {
                viewmodel.deleteLocalUserFavorite(favoriteUser.userId, completion: {
                    self?.showFavoriteUserList()
                })
            }
        }.disposed(by: cell.disposeBag)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return filteredSections[section].value.count > 0 ? filteredSections[section].key : nil
    }
}

// MARK: - Methods
extension FavoriteUserTableViewDataSource {
    private func makeFilteredSection() -> [UserSection] {
        favoriteUser
            .filter { check(name: $0.userName) }
            .reduce(into: [String: [LocalSerchUserInfo]]()) { dict, users in
                if let consonant = users.userName.initialConsonant()?.uppercased() {
                    dict[consonant, default: []].append(users)
                }
            }
            .sorted { $0.key < $1.key }
    }
    
    private func check(name: String?) -> Bool {
        guard let name = name?.lowercased() else { return false }
        let nameConsonants = name.compactMap { String($0).initialConsonant() }
        return name.hasPrefix(searchText) || nameConsonants.starts(with: searchedConsonants)
    }
}
