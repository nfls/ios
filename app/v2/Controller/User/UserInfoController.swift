//
//  UserInfoController.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/9/21.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import SwiftDate

class TypeCell: UITableViewCell {
    @IBOutlet weak var field: UITextField?
    @IBOutlet weak var submit: UIButton?
}


class UserInfoController: UITableViewController {
    let provider = UserProvider()
    let sections = ["个人信息", "安全设置", "隐私设置"]
    let numberOfRowsInSection = [5, 0, 0]
    override func viewDidLoad() {
        provider.getUser() {
            self.tableView.reloadData()
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSection[section]
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath) as! UITableViewCell
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "ID"
                cell.detailTextLabel?.text = String(provider.current!.id)
            case 1:
                cell.textLabel?.text = "CAS Hours"
                cell.detailTextLabel?.text = String(provider.current!.point)
            case 2:
                cell.textLabel?.text = "加入时间"
                cell.detailTextLabel?.text = provider.current!.joinTime?.toFormat("yyyy'年'MM'月'dd'日' HH:mm")
            case 3:
                cell.textLabel?.text = "手机"
                cell.detailTextLabel?.text = provider.current!.phone ?? "未绑定"
            case 4:
                cell.textLabel?.text = "邮箱"
                cell.detailTextLabel?.text = provider.current!.email ?? "未绑定"
            default:
                break
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        if provider.current == nil {
            return 0
        } else {
            return 3
        }
        
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
}
