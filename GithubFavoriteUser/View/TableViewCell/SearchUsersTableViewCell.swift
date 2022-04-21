//
//  SearchUsersTableViewCell.swift
//  GithubFavoriteUser
//
//  Created by JihoonKim on 2022/04/19.
//

import Foundation
import UIKit
import RxSwift

class SearchUsersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ivUserThumb: UIImageView!
    @IBOutlet weak var lbUserName: UILabel!
    @IBOutlet weak var btnSetFavorite: UIButton!
    
    var disposeBag = DisposeBag()
    
    //  Called when cells are reused
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        disposeBag = DisposeBag()
//    }
    
    func bindCell(_ userData: Any, cellType: SelectTabType)  {
        if cellType == .API {
            if let data = userData as? SearchUserInfo {
                CacheImage.sharedCacheImage.loadImageFromUrl(urlString: data.profileImg, imageView: ivUserThumb!)
                lbUserName.text = data.userName
                
                if data.isFavorite {
                    print(" data.userName \(data.userName)")
                    btnSetFavorite.setImage(UIImage(named: "icDetailPick24Select.png"), for: .normal)
                }
                else {
                    btnSetFavorite.setImage(UIImage(named: "icDetailPick24.png"), for: .normal)
                }
            }
        }
        else {
            if let data = userData as? LocalSerchUserInfo {
                CacheImage.sharedCacheImage.loadImageFromUrl(urlString: data.profileImg, imageView: ivUserThumb!)
                lbUserName.text = data.userName
                btnSetFavorite.setImage(UIImage(named: "icDetailPick24Select.png"), for: .normal)
            }
        }
    }
}
