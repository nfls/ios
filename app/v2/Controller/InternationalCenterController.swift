//
//  InternationalCenterController.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/9/23.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
class InternationalCenterController: UIViewController {
    
    @IBOutlet weak var paperView: PaperView!
    
    let problemProvider = ProblemProvider()
    override func viewDidLoad() {
        self.problemProvider.search(text: "use", precise: false, course: nil, isMultipleChoice: nil, size: 10  , page: 1) {
            self.paperView.setProblem(self.problemProvider.result[0])
        }
    }
}
