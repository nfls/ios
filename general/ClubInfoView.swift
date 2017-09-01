//
//  ClubInfoView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/9/1.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class ClubInfoViewController:UIViewController,UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var tableview: UITableView!
    let ID = "cell"
    override func viewDidLoad() {
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: ID)
        tableview.dataSource = self
        tableview.delegate = self
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ID, for: indexPath as IndexPath)
        //cell.textLabel!.text = names[indexPath.row]
        cell.textLabel!.text = "aaa"
        cell.sizeToFit()
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
    }
}
