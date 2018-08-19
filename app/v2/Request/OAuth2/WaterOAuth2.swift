//
//  WaterOAuth2.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/19.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import p2_OAuth2
import Moya

class WaterOAuth2 {
    let oauth2: OAuth2CodeGrant
    
    init() {
        oauth2 = OAuth2CodeGrant(settings: [
            "client_id": WaterConstant.client_id,
            "client_secret": WaterConstant.client_secret,
            "authorize_uri": "http://water.nfls.io/oauth/authorize",
            "token_uri": "https://water.nfls.io/oauth/accessToken",
            "redirect_uris": ["nfls://oauth/callback"],
            "scope": "",
            "secret_in_body": true,
            "keychain": false,
            "verbose": true
            ] as OAuth2JSON)
    }
    
    func login(completion: @escaping (_ success: Bool) -> Void) {
    
    }
    
    func getRequestClosure<T:TargetType>(type:T.Type) -> MoyaProvider<T> {
        let requestClosure:MoyaProvider<T>.RequestClosure = { (endpoint, done) in
            var request = try! endpoint.urlRequest() // This is the request Moya generates
            self.oauth2.authorize { (_, error) in
                if error != nil {
                    self.oauth2.forgetTokens()
                }
            }
            do {
                try request.sign(with: self.oauth2)
                done(.success(request))
            } catch {
                done(.success(request))
            }
        }
        let provider = MoyaProvider<T>(requestClosure: requestClosure)
        return provider
    }
}
