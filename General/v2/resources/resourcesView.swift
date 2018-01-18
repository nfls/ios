//
//  resourcesView.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 18/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import AliyunOSSiOS
import Alamofire
import SwiftyJSON

class ResourcesViewController:UITableViewController {
    let oauth2 = NFLSOauth2()
    override func viewDidLoad() {
        let req = oauth2.oauth2.request(forURL: URL(string: "https://api-v3.nfls.io/oauth/downloadSts")!)
        
        oauth2.oauth2.perform(request: req) { (response) in
            let data = try! JSON(data: response.data!)
            let provider = OSSStsTokenCredentialProvider(accessKeyId: data["data"]["AccessKeySecret"].string!, secretKeyId: data["data"]["AccessKeyId"].string!, securityToken: data["data"]["SecurityToken"].string!)
            let client = OSSClient(endpoint: "https://oss-cn-shanghai.aliyuncs.com", credentialProvider: provider)
            let bucket = OSSGetBucketRequest()
            bucket.bucketName = "nflsio"
            let task = client.getBucket(bucket)
            task.continue({ task -> Any? in
                print(task.error)
                //let result = task.result!
                //dump(result.contents)
            })
            //print(task.error)
        }
        
    }
}
