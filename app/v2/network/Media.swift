//
//  Gallery.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 21/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON

enum MediaRequest {
    case galleryList(page:Int)
    case galleryComment(id:Int,content:String)
    case list(page:Int)
}

extension MediaRequest:TargetType {
    var baseURL: URL {
        return URL(string: Constant.getApiUrl() + "media/")!
    }
    
    var path: String {
        switch self {
        case .list(_):
            return "list"
        case .galleryList(_):
            return "gallery/list"
        case .galleryComment(_):
            return "gallery/comment"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .list(_),.galleryList(_):
            return .get
        case .galleryComment(_,_):
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .galleryList(let page),.list(let page):
            return .requestParameters(parameters: ["page":page], encoding: URLEncoding.default)
        case .galleryComment(let id, let content):
            return .requestParameters(parameters: ["id":id,"content":content], encoding: JSONEncoding.default)

        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}

class MediaProvider:AbstractProvider<MediaRequest> {
    func getGalleryList(withPage page:Int, completion: @escaping (_ result: [Gallery]?) -> Void){
        self.provider.request(.galleryList(page: page)) { response in
            
            switch response {
            case .success(let data):
                do{
                    let response = try AbstractResponse<Gallery>(JSON: JSON(data.data).dictionaryObject!)
                    completion(response.data)
                }catch let error{
                    print(error)
                    completion(nil)
                }
            default:
                completion(nil)
                break
            }
        }
    }
}

