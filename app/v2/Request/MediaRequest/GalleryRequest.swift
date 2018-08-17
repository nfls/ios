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
    case list()
    case detail(id: Int)
    case comment(id: Int, content: String)
    case likeStatus()
    case like()
}

extension MediaRequest:TargetType {
    var baseURL: URL {
        return Constant.mainApiEndpoint.appendingPathComponent("media/gallery")
    }
    
    var path: String {
        switch self {
        case .likeStatus():
            return "status"
        default:
            return String(describing: self)
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .list(), .detail(_), .likeStatus():
            return .get
        case .comment(_, _), .like():
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        return .requestPlain //TODO: 
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
/*
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
*/
