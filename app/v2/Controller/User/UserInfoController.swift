//
//  UserInfoController.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/9/21.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import SwiftDate
import SDWebImage
import SCLAlertView
import ReCaptcha

class TypeCell: UITableViewCell {
    @IBOutlet weak var hint: UILabel!
    @IBOutlet weak var field: UITextField?
    @IBOutlet weak var submit: UIButton?
}

class AvatarCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView?
    @IBOutlet weak var username: UILabel?
}

class UserInfoController: UITableViewController {
    let provider = UserProvider()
    let sections = ["个人信息", "安全设置", "隐私设置"]
    let numberOfRowsInSection = [4, 2, 0]
    let recaptcha = try? ReCaptcha(endpoint: .default)
    
    @objc func changePhone(_ sender: UIButton) {
        let indexPath = IndexPath(row: 0, section: 1)
        let cell = self.tableView.cellForRow(at: indexPath) as! TypeCell
        self.handleClick(cell)
    }

    @objc func changeEmail(_ sender: UIButton) {
        let indexPath = IndexPath(row: 1, section: 1)
        let cell = self.tableView.cellForRow(at: indexPath) as! TypeCell
        self.handleClick(cell)
    }
    
    func handleClick(_ cell: TypeCell) {
        if cell.field!.isEnabled {
            //cell.submit?.isEnabled = false
            //recaptcha?.reset()
            recaptcha?.validate(on: view, resetOnError: true) { [weak self] (result: ReCaptchaResult) in
                print(try? result.dematerialize())
            }
        } else {
            cell.field!.isEnabled = true
            cell.field!.text = ""
            cell.field!.becomeFirstResponder()
            cell.submit?.setTitle("提交", for: [])
        }
    }
        
    override func viewDidLoad() {
        self.tableView.allowsSelection = false
        recaptcha?.configureWebView { [weak self] webview in
            webview.frame = CGRect(x: 0, y: 40, width: self?.view.bounds.width ?? 0, height: self?.view.bounds.height ?? 0)
        }
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath) as UITableViewCell
            switch indexPath.row {
            case 0:
                let avatar = tableView.dequeueReusableCell(withIdentifier: "avatarCell", for: indexPath) as! AvatarCell
                avatar.avatar?.sd_setImage(with: provider.current!.avatar, completed: nil)
                avatar.username?.text = provider.current!.username
                return avatar
            case 1:
                cell.textLabel?.text = "ID"
                cell.detailTextLabel?.text = String(provider.current!.id)
            case 2:
                cell.textLabel?.text = "CAS Hours"
                cell.detailTextLabel?.text = String(provider.current!.point)
            case 3:
                cell.textLabel?.text = "加入时间"
                cell.detailTextLabel?.text = provider.current!.joinTime?.toFormat("yyyy'年'MM'月'dd'日' HH:mm")
            default:
                break
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "typeCell", for: indexPath) as! TypeCell
            switch indexPath.row {
            case 0:
                cell.hint?.text = "手机"
                cell.field?.text = provider.current!.phone ?? "未绑定"
                cell.submit?.addTarget(self, action: #selector(changePhone(_:)), for: .touchDown)
                cell.submit?.tag = 0
            case 1:
                cell.hint?.text = "邮箱"
                if let email = provider.current?.email {
                    cell.field?.text = email
                    cell.submit?.isEnabled = false
                } else {
                    cell.field?.text = "未绑定"
                    cell.submit?.addTarget(self, action: #selector(changeEmail(_:)), for: .touchDown)
                    cell.submit?.tag = 1
                }
            default:
                break
            }
            return cell
        default:
            break
        }
        return UITableViewCell()
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
