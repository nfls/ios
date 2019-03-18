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
import YPImagePicker

class TypeCell: UITableViewCell {
    @IBOutlet weak var hint: UILabel!
    @IBOutlet weak var field: UITextField?
    @IBOutlet weak var submit: UIButton?
}

class AvatarCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView?
    @IBOutlet weak var username: UILabel?
}

class PrivacyCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var picker: UIPickerView?
    @IBOutlet weak var submit: UIButton?
    @IBOutlet weak var antiSpider: UISwitch?
    
    let data = ["仅同校学生 (所有实名用户)", "仅同届同学", "仅自己"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.data.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.data[row]
    }
}

class UserInfoController: UITableViewController {
    let provider = UserProvider()
    let sections = ["个人信息", "安全设置", "隐私设置"]
    let numberOfRowsInSection = [4, 3, 1]
    var recaptcha = try? ReCaptcha(endpoint: .default)
    let completion: (String?) -> Void = { response in
        if let response = response {
            SCLAlertView().showError("错误", subTitle: response)
        } else {
            MessageNotifier().showInfo("修改成功")
        }
        load()
    }
    
    @objc func changePhone(_ sender: UIButton) {
        let indexPath = IndexPath(row: 0, section: 1)
        let cell = self.tableView.cellForRow(at: indexPath) as! TypeCell
        self.handleClick(cell, isPhone: true)
    }

    @objc func changeEmail(_ sender: UIButton) {
        let indexPath = IndexPath(row: 1, section: 1)
        let cell = self.tableView.cellForRow(at: indexPath) as! TypeCell
        self.handleClick(cell, isPhone: false)
    }
    
    @objc func changeUsername() {
        let prompt = SCLAlertView()
        let username = prompt.addTextField("新用户名")
        prompt.addButton("提交") {
            self.provider.changeUsername(username.text ?? "", completion: self.completion)
        }
        prompt.showInfo("修改用户名", subTitle: "用户名支持中文、英文、日文，长度在3-16之间。每次改名需要2小时的\"创意、活动、服务\"。", closeButtonTitle: "取消")
    }
    
    @objc func changePassword(_ sender: UIButton) {
        let indexPath = IndexPath(row: 2, section: 1)
        let cell = self.tableView.cellForRow(at: indexPath) as! TypeCell
        let prompt = SCLAlertView()
        let password = prompt.addTextField("原密码")
        prompt.addButton("提交") {
            self.provider.changeSecurity(password: password.text ?? "", newPassword: cell.field?.text ?? "", newEmail: nil, newPhone: nil, phoneCode: nil, emailCode: nil, clean: true, completion: self.completion)
        }
        prompt.showInfo("修改密码", subTitle: "请输入您原来的密码以修改。请注意，您所有登录的设备在修改密码后会自动退出。", closeButtonTitle: "取消")
    }
    
    @objc func changeAvatar(_ imageView: UIImageView) {
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photo
        config.startOnScreen = .library
        config.showsCrop = .rectangle(ratio: 1.0/1.0)
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { (items, _) in
            if let photo = items.singlePhoto {
                let loading = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false)).showWait("请稍后", subTitle: "图片上传中，大概需要半分钟")
                self.provider.changeAvatar(photo.image, completion: {
                    loading.close()
                    let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! AvatarCell
                    cell.avatar?.sd_setImage(with: self.provider.current?.avatar, placeholderImage: nil, options: .refreshCached, progress: nil, completed: nil)
                })
            }
            picker.dismiss(animated: true)
        }
        self.present(picker, animated: true)
    }
    
    func handleClick(_ cell: TypeCell, isPhone: Bool) {
        if cell.field!.isEnabled {
            cell.field!.isEnabled = false
            if isPhone {
                self.sendCode(toPhone: cell.field?.text ?? "", completion: {
                    cell.field!.isEnabled = true
                })
            } else {
                self.sendCode(toEmail: cell.field?.text ?? "", completion: {
                    cell.field!.isEnabled = true
                })
            }
        } else {
            cell.field!.isEnabled = true
            cell.field!.text = ""
            cell.field!.becomeFirstResponder()
            cell.submit?.setTitle("提交", for: [])
        }
    }
    
    func sendCode(toPhone phone: String, completion: @escaping ()->Void) {
        self.provider.postSendRequest(toPhone: phone) { (message) in
            completion()
            if let message = message {
                SCLAlertView().showError("错误", subTitle: message)
            } else {
                self.showPromptForCode(entry: phone, isPhone: true)
            }
        }
    }
    
    func sendCode(toEmail email: String, completion: @escaping ()->Void) {
        self.provider.postSendRequest(toEmail: email) { (message) in
            completion()
            if let message = message {
                SCLAlertView().showError("错误", subTitle: message)
            } else {
                self.showPromptForCode(entry: email, isPhone: false)
            }
        }
    }
    
    func showPromptForCode(entry: String, isPhone: Bool) {
        let prompt = SCLAlertView()
        let code = prompt.addTextField("动态码")
        code.autocorrectionType = .no
        code.autocapitalizationType = .none
        let password = prompt.addTextField("账户密码")
        password.isSecureTextEntry = true
        prompt.addButton("确认") {
            if isPhone {
                self.provider.changeSecurity(password: password.text ?? "", newPassword: nil, newEmail: nil, newPhone: entry, phoneCode: code.text ?? "", emailCode: nil, clean: nil, completion: self.completion)
            } else {
                self.provider.changeSecurity(password: password.text ?? "", newPassword: nil, newEmail: entry, newPhone: nil, phoneCode: nil, emailCode: code.text ?? "", clean: nil, completion: self.completion)
            }
        }
        prompt.showInfo("信息确认", subTitle: "请输入您收到的动态码，并输入您账户的密码以确认", closeButtonTitle: "取消")
    }
    
    func load() {
        provider.getUser() {
            self.tableView.reloadData()
        }
    }
        
    override func viewDidLoad() {
        self.tableView.allowsSelection = false
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
        recaptcha?.configureWebView { [weak self] webview in
            webview.frame = CGRect(x: 0, y: 40, width: self?.view.bounds.width ?? 0, height: self?.view.bounds.height ?? 0)
        }
        self.load()
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
                avatar.avatar?.isUserInteractionEnabled = true
                avatar.avatar?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeAvatar(_:))))
                avatar.username?.isUserInteractionEnabled = true
                avatar.username?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeUsername)))
                return avatar
            case 1:
                cell.textLabel?.text = "ID"
                cell.detailTextLabel?.text = String(provider.current!.id)
            case 2:
                cell.textLabel?.text = "\"创意、行动、服务\" 小时数"
                cell.detailTextLabel?.text = String(provider.current!.point)
            case 3:
                cell.textLabel?.text = "加入时间"
                cell.detailTextLabel?.text = provider.current!.joinTime?.toFormat("yyyy'/'MM'/'dd HH:mm")
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
            case 2:
                cell.hint?.text = "密码"
                cell.submit?.toolbarPlaceholder = "新密码"
                cell.submit?.addTarget(self, action: #selector(changePassword(_:)), for: .touchDown)
                cell.field?.isEnabled = true
            default:
                break
            }
            return cell
        case 2:
            switch indexPath.row {
            case 0:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "privacyCell", for: indexPath) as! PrivacyCell
                cell.picker?.delegate = cell
                cell.picker?.dataSource = cell
                return cell
            default:
                break
            }
        default:
            break
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            let name = Bundle.main.infoDictionary?["CFBundleDisplayName"] as! String
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
            let code = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
            let jp = Bundle.main.infoDictionary?["CodeNameJP"] as! String
            let en = Bundle.main.infoDictionary?["CodeNameEN"] as! String
            return  "\(name) \(version)(\(code)), \(jp)(\(en)), © 2017-2019 胡清阳 "
        } else {
            return nil
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        if provider.current == nil {
            return 0
        } else {
            return 2
        }
        
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
}
