//
//  PastPaper.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 22/02/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import Cache
import AliyunOSSiOS
import FileKit

enum SchoolRequest {
    case pastpaperToken()
    case pastpaperHeader()
    case blackboardList()
    case blackboardDetail(id:String, page:Int?)
}

extension SchoolRequest: TargetType {
    var baseURL: URL {
        return URL(string: Constant.getApiUrl() + "school/")!
    }
    
    var path: String {
        switch self {
        case .pastpaperToken():
            return "pastpaper/token"
        case .pastpaperHeader():
            return "pastpaper/header"
        case .blackboardList():
            return "blackboard/list"
        case .blackboardDetail(_, _):
            return "blackboard/detail"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .pastpaperToken():
            return .requestPlain
        case .pastpaperHeader():
            return .requestPlain
        case .blackboardList():
            return .requestPlain
        case .blackboardDetail(let id, let page):
            if let page = page {
                return .requestParameters(parameters: ["id":id,"page":page], encoding: URLEncoding.default)
            } else {
                return .requestParameters(parameters: ["id":id], encoding: URLEncoding.default)
            }
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}

class SchoolProvider:Network<SchoolRequest> {
    //fileprivate var files = [File]()
    fileprivate var isLoaded = false
    
    public var path = [String]()
    
    var client:OSSClient? = nil
    
    public func getFileList(completion: @escaping (_ files:[File]) -> Void)
    {
        if let files = try? self.cache.object(ofType: [File].self, forKey: "school.pastpaper.list.cache") {
            completion(self.filter(files))
        }
        if !self.isLoaded {
            self.isLoaded = true
            self.getList(completion: completion)
        }
    }
    
    public func getFile(file:File, progress: @escaping (_ precentage:Double) -> Void, completion: @escaping (_ succeeded:Bool) -> Void)
    {
        if let client = client {
            let request = OSSGetObjectRequest()
            request.bucketName = "nfls-papers"
            request.downloadProgress = { bytesWritten, totalBytesWritten, bytesExpectedToWritten in
                progress(Double(totalBytesWritten)/Double(bytesExpectedToWritten))
            }
            let task = client.getObject(request)
            task.continue({ task -> Any? in
                if let error = task.error {
                    print(error)
                }else{
                    
                    let result = task.result as! OSSGetObjectResult
                    do {
                        try? result.downloadedData |> DataFile(path: file.name)
                    } catch let error {
                        
                    }
                    completion(true)
                    //try? result.downloadedData |> DataFile(path: path + filename)
                }
                return task
            })
        } else {
            completion(false)
        }
    }
    
    fileprivate func getList(completion: @escaping (_ files:[File]) -> Void)
    {
        self.request(target: .pastpaperToken(), type: StsToken.self, success: { response in
            let token = response
            let stsTokenProvider = OSSStsTokenCredentialProvider(accessKeyId: token.accessKeyId, secretKeyId: token.accessKeySecret, securityToken: token.securityToken)
            self.client = OSSClient(endpoint: "https://oss-cn-shanghai.aliyuncs.com", credentialProvider: stsTokenProvider)
            self.requestList(result:[], next: nil, completion: completion)
        })
    }
    
    fileprivate func requestList(result:[File] = [],next:String? = nil, completion: @escaping (_ files:[File]) -> Void)
    {
        if let client = client {
            var files = result
            let bucket = OSSGetBucketRequest()
            bucket.bucketName = "nfls-papers"
            bucket.maxKeys = 1000
            bucket.marker = next ?? ""
            let task = client.getBucket(bucket)
            task.continue({ rsp -> Any? in
                if let t = (rsp.result as? OSSGetBucketResult) {
                    if let contents = t.contents {
                        for object in contents{
                            let data = object as! [String:Any]
                            files.append(File(data))
                        }
                        self.requestList(result: files, next: (t.contents!.last as! [String:Any])["Key"] as? String, completion: completion)
                    }else{
                        try? self.cache.setObject(files, forKey: "school.pastpaper.list.cache")
                        completion(self.filter(files))
                    }
                } else {
                    print(rsp.error)
                }
                return task
            })
        }
        
    }
    
    fileprivate func filter(_ files:[File]) -> [File]
    {
        let realPath = self.getPath()
        return files.filter({ file -> Bool in
            return (file.name.components(separatedBy: "/").count == path.count + 1) && file.name.hasPrefix(realPath)
        })
    }
    
    fileprivate func getPath() -> String {
        return (path as NSArray).componentsJoined(by: "/")
    }
}
