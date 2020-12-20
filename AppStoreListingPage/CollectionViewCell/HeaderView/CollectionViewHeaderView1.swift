//
//  CollectionViewHeaderView1.swift
//  AppStoreListingPage
//
//  Created by DIUUMA on 19/12/2020.
//

import UIKit

class CollectionViewHeaderView1: UICollectionReusableView {

    @IBOutlet weak var headerLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        headerLb.text = ""
    }
    
}
