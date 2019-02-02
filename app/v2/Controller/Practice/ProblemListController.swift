//
//  ProblemListController.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/10/1.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import TesseractOCR

class ProblemListController: UITableViewController {
    let problemProvider = ProblemProvider()
    var text: String = ""
    override func viewDidLoad() {
        self.problemProvider.search(text: self.text, precise: false, course: nil, isMultipleChoice: nil, size: 10  , page: 1) {
            //dump(self.problemProvider.result)
            self.tableView.reloadData()
        }
        self.tableView.estimatedRowHeight = 800
        self.tableView.rowHeight = 800
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return problemProvider.result.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "problemCell", for: indexPath) as! ProblemCell
        cell.setProblem(problemProvider.result[indexPath.row])
        //dump(problemProvider.result[indexPath.row])
        return cell
    }
}
