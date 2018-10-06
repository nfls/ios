//
//  PaperProvider.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/9/30.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation

class PaperProvider: AbstractProvider<PaperRequest> {
    var list: [Paper] = []
    //var detail:
    public func load(withCourse course: UUID, completion: @escaping ()->Void) {
        self.request(target: PaperRequest.list(id: course), type: ListWrapper<Paper>.self, success: { response in
            self.list = response.data.list
            completion()
        })
    }
    
    public func detail(withPaper paper: UUID, completion: @escaping ()->Void) {
        self.request(target: PaperRequest.detail(id: paper), type: ListWrapper<Problem>.self, success: { response in
            
        })
    }
}
