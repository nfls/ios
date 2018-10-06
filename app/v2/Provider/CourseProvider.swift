//
//  CourseProvider.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/9/29.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation

class CourseProvider: AbstractProvider<CourseRequest> {
    var list: [Course] = []
    public func load(_ completion: @escaping ()-> Void) {
        self.request(target: CourseRequest.all(), type: ListWrapper<Course>.self, success: {response in
            self.list = response.data.list
            completion()
        })
    }
}
