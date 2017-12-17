//
//  AvailablePeopleView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/12/7.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit

class AvailablePeopleView:UITableViewController{
    var classList = [PhotoViewController.Class]()
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classList[section].people.count
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return classList.count
    }
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var name = [String]()
        for claz in classList{
            name.append(claz.name)
        }
        return name
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ID")!
        cell.textLabel?.text = classList[indexPath.section].people[indexPath.row].name
        return cell
    }
}
