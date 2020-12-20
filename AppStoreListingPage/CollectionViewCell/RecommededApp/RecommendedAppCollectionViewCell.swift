//
//  RecommendedAppCollectionViewCell.swift
//  AppStoreListingPage
//
//  Created by DIUUMA on 19/12/2020.
//

import UIKit

class RecommendedAppCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var appIconImg: UIImageView!
    @IBOutlet weak var appNameTitle: UILabel!
    @IBOutlet weak var appCategoryLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        appIconImg.layer.cornerRadius = 20.0
    }

}
