//
//  SearchUserViewController.swift
//  GithubFavoriteUser
//
//  Created by JihoonKim on 2022/04/18.
//

import UIKit
import RxSwift
import RxGesture


enum SelectTabType {
    case API
    case LOCAL
}

class SearchUserViewController: UIViewController {
    
    @IBOutlet weak var tvSearchResult: UITableView!
    @IBOutlet weak var tfSearchUserKeyword: UITextField!
    
    @IBOutlet weak var vApiTab: UIView!
    @IBOutlet weak var vApiTabLine: UIView!
    
    @IBOutlet weak var vLocalTab: UIView!
    @IBOutlet weak var vLocalTabLine: UIView!
    
    @IBOutlet weak var vEmpty: UIView!
    
    private let disposeBag = DisposeBag()
    private var users = [SearchUserInfo]()
    public var viewModel = SearchUsersViewModel(GithubFavoriteUserService())
    
    private var dataSource = FavoriteUserTableViewDataSource()
    
    private var selectType = SelectTabType.API
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vApiTab.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.selectTab(.API)
            }).disposed(by: self.disposeBag)
        
        vLocalTab.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.selectTab(.LOCAL)
            }).disposed(by: self.disposeBag)
        
        tvSearchResult.rx.didScroll.subscribe { [weak self] _ in
            guard let self = self else { return }
            let offSetY = self.tvSearchResult.contentOffset.y
            let contentHeight = self.tvSearchResult.contentSize.height
            
            if offSetY > (contentHeight - self.tvSearchResult.frame.size.height - 100) {
                self.viewModel.getNextPageSearchUser(keyword: self.tfSearchUserKeyword.text ?? "")
            }
        }.disposed(by: disposeBag)
        
        selectTab(.API)
    }
    
    private func selectTab(_ type: SelectTabType){
        selectType = type
        viewModel.clearUserData()
        
        tvSearchResult.delegate = nil
        tvSearchResult.dataSource = nil
        
        switch type {
        case .API:
            vApiTabLine.isHidden = false
            vLocalTabLine.isHidden = true
            viewModel.users
                .observe(on: MainScheduler.instance)
                .bind(to: self.tvSearchResult.rx.items(cellIdentifier: "SearchUsersCell", cellType: SearchUsersTableViewCell.self)) { index, item, cell in
                    cell.disposeBag = DisposeBag()
                    
                    self.viewModel.favoriteUsers.subscribe(onNext: { 
                        $0.forEach {
                            if $0.userId == item.userId {
                                item.isFavorite = true
                            }
                        }
                    }).disposed(by: self.disposeBag)
                    
                    cell.bindCell(item, cellType: .API)
                    
                    cell.btnSetFavorite.rx.tap.bind { [weak self] in
                        self?.viewModel.updateLocalUsersFavorite(item)
                        self?.tvSearchResult.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                    }.disposed(by: cell.disposeBag)
                }
                .disposed(by: self.disposeBag)
            
        case .LOCAL:
            
            vApiTabLine.isHidden = true
            vLocalTabLine.isHidden = false
            
            dataSource.viewModel = self.viewModel
            dataSource.dataDidUpdated = { [weak self] in
                guard let self = self else { return }
                self.tvSearchResult.reloadData()
            }
            
            self.tvSearchResult.dataSource = dataSource
            
            dataSource.showFavoriteUserList()
            self.tvSearchResult.reloadData()
            
            viewModel.favoriteUsers.subscribe(onNext: {_ in
                self.tvSearchResult.reloadData()
            }).disposed(by: self.disposeBag)
            
            viewModel.getLocalUsers()
        }
        
        tfSearchUserKeyword.text = ""
    }
}

extension SearchUserViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let searchText =  textField.text {
            if selectType == .API {
                viewModel.getSearchUsers(keyword: searchText)
            }
            else {
                dataSource.searchText = searchText
            }
        }
        return true
    }
}
