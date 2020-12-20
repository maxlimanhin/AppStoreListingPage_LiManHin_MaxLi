//
//  ViewController.swift
//  AppStoreListingPage
//
//  Created by DIUUMA on 19/12/2020.
//

import UIKit
import Kingfisher

class ViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UIScrollViewDelegate {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var recommendAppCollectionView: UICollectionView!
    private var lastFreeAppTableViewContentOffset: CGFloat = 0
    @IBOutlet weak var freeAppTableView: UITableView!
    @IBOutlet weak var freeAppTableViewHeightConstraint: NSLayoutConstraint!
    
    let recommendAppListLimit = 10
    var recommendAppList:[AppInfo] = []
    var filtedRecommendAppList:[AppInfo] = []
    
    let freeAppListLimit = 100
    var freeAppFullList:[AppInfo] = []
    var freeAppList:[AppInfo] = []
    var filtedFreeAppList:[AppInfo] = []
    
    var isSearching = false
    var isGettingAppInfoDetails = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.searchBar.delegate = self
        self.scrollView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTableView), name: NSNotification.Name(rawValue: "reloadFreeAppList"), object: nil)
        
        self.freeAppTableView.delegate = self
        self.freeAppTableView.dataSource = self
        self.freeAppTableView.register(UINib(nibName: "FreeAppTableViewCell", bundle: nil), forCellReuseIdentifier: "freeAppTableViewCell")
        
        self.recommendAppCollectionView.delegate = self
        self.recommendAppCollectionView.dataSource = self
        self.recommendAppCollectionView.register(UINib(nibName: "RecommendedAppCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "recommendedAppCollectionViewCell")
        
        self.loadingIndicator.startAnimating()
        self.loadingIndicator.isHidden = false
        apiController.getRecommendAppList(limit: recommendAppListLimit) { (success, recommandAppList) in
            DispatchQueue.main.async {
                if success {
                    self.recommendAppList = recommandAppList.sorted(by: {$0.order! < $1.order!})
                    self.filtedRecommendAppList = self.recommendAppList
                } else {
                    self.recommendAppList = []
                    self.filtedRecommendAppList = []
                    self.showAlertView(title: "Sorry!", msg: "An error occurred please try again later")
                }
                self.recommendAppCollectionView.reloadData()
                apiController.getTopFreeAppList(limit: self.freeAppListLimit) { (success, topfreeAppList) in
                    DispatchQueue.main.async {
                        if success {
                            self.freeAppFullList = topfreeAppList.sorted(by: {$0.order! < $1.order!})
                            self.freeAppList = []
                            self.filtedFreeAppList = []
                            self.loadAppInfoDetail()
                        } else {
                            self.showAlertView(title: "Sorry!", msg: "An error occurred please try again later")
                            self.freeAppFullList = []
                            self.freeAppList = []
                            self.filtedFreeAppList = []
                        }
                        self.freeAppTableView.reloadData()
                    }
                }
            }
        }
    }
    
    func loadAppInfoDetail() {
        if isGettingAppInfoDetails && isSearching {
            return
        } else {
            isGettingAppInfoDetails = true
            self.loadingIndicator.startAnimating()
            self.loadingIndicator.isHidden = false
            var count = 0
            let currentFreeAppIndex = self.freeAppList.count
            if currentFreeAppIndex < self.freeAppFullList.count {
                for i in currentFreeAppIndex..<(currentFreeAppIndex + 10) {
                    apiController.getAppDetailByAppID(app: self.freeAppFullList[i]) { (success, appInfo) in
                        count += 1
                        self.freeAppList.append(appInfo)
                        if count == 10 {
                            DispatchQueue.main.async {
                                self.loadingIndicator.stopAnimating()
                                self.freeAppList = self.freeAppList.sorted(by: {$0.order! < $1.order!})
                                self.isGettingAppInfoDetails = false
                                NotificationCenter.default.post(name: Notification.Name("reloadFreeAppList"), object: nil)
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    func showAlertView(title: String, msg: String ){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    //MARK:- Collection View
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filtedRecommendAppList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendedAppCollectionViewCell", for: indexPath) as! RecommendedAppCollectionViewCell
        let appInfo = self.filtedRecommendAppList[indexPath.row]
        cell.appNameTitle.text = appInfo.appName
        cell.appCategoryLb.text = appInfo.appCategoryString
        if let imageUrl = URL(string: appInfo.appIconURL ?? ""){
            cell.appIconImg.kf.setImage(with: imageUrl)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "collectionViewHeaderView1", for: indexPath) as! CollectionViewHeaderView1
            headerView.headerLb.text = "推介"
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100.0, height: 160.0)
    }
    
    
    //MARK:- Table View
    @objc func reloadTableView() {
        if self.searchBar.text == "" {
            self.filtedFreeAppList = self.freeAppList
        } else {
            self.filtedFreeAppList = []
            for app in self.freeAppList {
                if (app.appAuthorName ?? "").contains(self.searchBar.text ?? "") || (app.appSummary ?? "").contains(self.searchBar.text ?? "") || (app.appCategoryString ?? "").contains(self.searchBar.text ?? "") || (app.appName ?? "").contains(self.searchBar.text ?? "") {
                    self.filtedFreeAppList.append(app)
                }
            }
        }
        self.freeAppTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.freeAppTableViewHeightConstraint.constant = CGFloat(100 * self.filtedFreeAppList.count)
        self.view.layoutIfNeeded()
        return self.filtedFreeAppList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "freeAppTableViewCell", for: indexPath) as! FreeAppTableViewCell
        let appInfo = self.filtedFreeAppList[indexPath.row]
        cell.orderLb.text = "\(indexPath.row + 1)"
        cell.appNameLb.text = appInfo.appName
        cell.appCategoryLb.text = appInfo.appCategoryString
        
        if let imageUrl = URL(string: appInfo.appIconURL ?? ""){
            cell.appIconImg.kf.setImage(with: imageUrl)
        }
        cell.setupRating(Rating: appInfo.appRating ?? 0, RatingCount: appInfo.appRatingCount ?? 0)
        
        if ((indexPath.row + 1 ) % 2) == 0 {
            cell.appIconImg.layer.cornerRadius = cell.appIconImg.layer.frame.height/2
        } else {
            cell.appIconImg.layer.cornerRadius = 20.0
        }
        return cell
    }

    
    //MARK:- Search Bar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.isSearching = false
            self.filtedRecommendAppList = self.recommendAppList
            self.filtedFreeAppList = self.freeAppList
        } else {
            self.isSearching = true
            self.filtedRecommendAppList = []
            for app in self.recommendAppList {
                if (app.appAuthorName ?? "").contains(searchText) || (app.appSummary ?? "").contains(searchText) || (app.appCategoryString ?? "").contains(searchText) || (app.appName ?? "").contains(searchText) {
                    self.filtedRecommendAppList.append(app)
                }
            }
            self.filtedFreeAppList = []
            for app in self.freeAppList {
                if (app.appAuthorName ?? "").contains(searchText) || (app.appSummary ?? "").contains(searchText) || (app.appCategoryString ?? "").contains(searchText) || (app.appName ?? "").contains(searchText) {
                    self.filtedFreeAppList.append(app)
                }
            }
           
        }
        self.recommendAppCollectionView.reloadData()
        self.freeAppTableView.reloadData()
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isGettingAppInfoDetails){
                self.loadAppInfoDetail()
            }
        }
    }
}

