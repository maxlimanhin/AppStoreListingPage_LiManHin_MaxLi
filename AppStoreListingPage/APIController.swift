//
//  APIController.swift
//  AppStoreListingPage
//
//  Created by DIUUMA on 19/12/2020.
//

import Foundation
import Alamofire
import SwiftyJSON

let apiController = APIController()

class APIController {
    var manager = Session.default

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30;
        manager = Session(configuration: configuration)
    }
    
    func getRecommendAppList(limit: Int, callback:  @escaping (Bool, [AppInfo])->()) {
        let urlString = "https://itunes.apple.com/hk/rss/topgrossingapplications/limit=\(limit)/json"
        let parameters = [:] as [String: Any]
        AF.request(urlString, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                var recommandAppList:[AppInfo] = []
                for eachApp in json["feed"]["entry"] {
                    let appOrder = eachApp.0
                    let appContent = eachApp.1
                    let appID = appContent["id"]["attributes"]["im:id"].stringValue
                    let appName = appContent["im:name"]["label"].stringValue
                    let appImageURL = appContent["im:image"].arrayValue[1]["label"].stringValue
                    let appCategory = appContent["category"]["attributes"]["label"].stringValue
                    let appAuthorName = appContent["im:artist"]["label"].stringValue
                    let appSummary = appContent["summary"]["label"].stringValue
                    let newAppInfo = AppInfo.init(order: appOrder, appID: appID, appName: appName, appIconURL: appImageURL, appCategoryString: appCategory, appAuthorName: appAuthorName, appSummary: appSummary, appRating: 0, appRatingCount: 0)
                    recommandAppList.append(newAppInfo)
                }
                callback(true, recommandAppList)
            case .failure(_):
                callback(false, [])
            }
        }
    }
    
    func getTopFreeAppList(limit: Int,  callback:  @escaping (Bool, [AppInfo])->()) {
        let urlString = "https://itunes.apple.com/hk/rss/topfreeapplications/limit=\(limit)/json"
        let parameters = [:] as [String: Any]
        AF.request(urlString, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                var freeAppList:[AppInfo] = []
                for eachApp in json["feed"]["entry"] {
                    let appOrder = eachApp.0
                    let appContent = eachApp.1
                    let appID = appContent["id"]["attributes"]["im:id"].stringValue
                    let appName = appContent["im:name"]["label"].stringValue
                    let appImageURL = appContent["im:image"].arrayValue[1]["label"].stringValue
                    let appCategory = appContent["category"]["attributes"]["label"].stringValue
                    let appAuthorName = appContent["im:artist"]["label"].stringValue
                    let appSummary = appContent["summary"]["label"].stringValue
                    let newAppInfo = AppInfo.init(order: appOrder, appID: appID, appName: appName, appIconURL: appImageURL, appCategoryString: appCategory, appAuthorName: appAuthorName, appSummary: appSummary, appRating: 0, appRatingCount: 0)
                    freeAppList.append(newAppInfo)
                }
                callback(true, freeAppList)
            case .failure(_):
                callback(false, [])
            }
        }
    }
    
    
    func getAppDetailByAppID(app: AppInfo, callback:  @escaping (Bool, AppInfo)->()) {
        let urlString = "https://itunes.apple.com/hk/lookup?id=\(app.appID ?? "")"
        let parameters = [:] as [String: Any]
        AF.request(urlString, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                var userRatingCount = 0
                var rating = 0
                for each in json["results"] {
                    let appContent = each.1
                    userRatingCount = Int(appContent["userRatingCount"].int64Value)
                    rating = Int((appContent["averageUserRating"].doubleValue).rounded(.up))
                }
                let updatedAppInfo = AppInfo.init(order: app.order, appID: app.appID, appName: app.appName, appIconURL: app.appIconURL, appCategoryString: app.appCategoryString, appAuthorName: app.appCategoryString, appSummary: app.appSummary, appRating: rating, appRatingCount: userRatingCount)
                callback(true, updatedAppInfo)
                break
            case .failure(_):
                callback(false, app)
                break
            }
        }
    }
}

