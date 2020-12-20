//
//  FreeAppTableViewCell.swift
//  AppStoreListingPage
//
//  Created by DIUUMA on 19/12/2020.
//

import UIKit

class FreeAppTableViewCell: UITableViewCell {

    @IBOutlet weak var orderLb: UILabel!
    @IBOutlet weak var appIconImg: UIImageView!
    @IBOutlet weak var appNameLb: UILabel!
    @IBOutlet weak var appCategoryLb: UILabel!

    @IBOutlet weak var star1_img: UIImageView!
    @IBOutlet weak var star2_img: UIImageView!
    @IBOutlet weak var star3_img: UIImageView!
    @IBOutlet weak var star4_img: UIImageView!
    @IBOutlet weak var star5_img: UIImageView!
    @IBOutlet weak var ratingCountLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.orderLb.text = ""
        self.appIconImg.image = nil
        self.appNameLb.text = ""
        self.appCategoryLb.text = ""
        self.star1_img.image = UIImage.init(systemName: "star")
        self.star2_img.image = UIImage.init(systemName: "star")
        self.star3_img.image = UIImage.init(systemName: "star")
        self.star4_img.image = UIImage.init(systemName: "star")
        self.star5_img.image = UIImage.init(systemName: "star")
        self.ratingCountLb.text = ""
    }
    
    func setupRating(Rating:Int, RatingCount: Int) {
        self.ratingCountLb.text = ""
        if Rating >= 1 {
            self.star1_img.image = UIImage.init(systemName: "star.fill")
        }
        if Rating >= 2 {
            self.star2_img.image = UIImage.init(systemName: "star.fill")
        }
        if Rating >= 3 {
            self.star3_img.image = UIImage.init(systemName: "star.fill")
        }
        if Rating >= 4 {
            self.star4_img.image = UIImage.init(systemName: "star.fill")
        }
        if Rating >= 5 {
            self.star5_img.image = UIImage.init(systemName: "star.fill")
        }
        self.ratingCountLb.text = "(\(RatingCount))"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
}
