//
//  ProblemProvider.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/10/1.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation

class ProblemProvider: AbstractProvider<ProblemRequest> {
    var result: [Problem] = []
    var list: [Problem] = []
    func search(text: String, precise: Bool, course: UUID?, isMultipleChoice: Bool?, size: Int, page: Int, completion: @escaping () -> Void) {
        self.request(target: ProblemRequest.search(text: text, precise: precise, course: course, isMultipleChoice: isMultipleChoice, size: size, page: page), type: ListWithCount<Problem>.self, success:  { (response) in
            self.result = response.data.result
            completion()
        })
    }
    
    func list(withPaper paper: UUID, completion: @escaping () -> Void) {
        self.request(target: ProblemRequest.list(id: paper), type: ListWrapper<Problem>.self, success: { response in
            self.list = response.data.list
            completion()
        })
    }
    
}
