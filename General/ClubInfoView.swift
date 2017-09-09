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
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var comment: UITextField!
    @IBOutlet weak var added_by: UITextField!
    @IBOutlet weak var barbutton: UIBarButtonItem!
    var selected = [Int]()
    var names = [String]()
    var ids = [Int]()
    var action = "edit"
    var id = 0
    var first = true
    override func viewDidAppear(_ animated: Bool) {
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: ID)
        tableview.dataSource = self
        tableview.delegate = self
        added_by.isEnabled = false
        disableFields()
        if(id != 0){
            loadData(id)
        } else if(action == "edit" && selected.isEmpty){
            if(first){
                loadMessage(true)
            }
        } else if (action == "edit" && !selected.isEmpty){
            prepareList()
        } else if (action == "new"){
            self.cleanFields()
            self.enableFields()
        }
    }
    @IBAction func showMenu(_ sender: Any) {
        let menu = UIAlertController(title: "操作", message: "新建社团前请先进入查询社团模块", preferredStyle: .actionSheet)
        let query = UIAlertAction(title: "查询社团", style: .default, handler: {
            action in
            self.performSegue(withIdentifier: "showTableSelect2", sender: "club")
        })
        let save = UIAlertAction(title: "保存数据", style: .default, handler: {
            action in
            self.saveData()
        })
        let add = UIAlertAction(title: "添加到我的列表", style: .default, handler: {
            action in
            self.saveData(true)
        })
        let showNotice = UIAlertAction(title: "显示提示", style: .default, handler:{
            action in
            self.loadMessage(false)
        })
        let exitWithoutSave = UIAlertAction(title: "不保存退出", style: .destructive) { (action) in
            self.performSegue(withIdentifier: "backToCertification", sender: self)
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        menu.addAction(query)
        if(!(id == 0 && action == "edit")){
            menu.addAction(save)
        }
        if(id != 0){
            menu.addAction(add)
        }
        menu.addAction(showNotice)
        if(self.presentingViewController is UserCertificationStepView){
            menu.addAction(exitWithoutSave)
        }
        menu.addAction(cancel)
        menu.popoverPresentationController?.barButtonItem = barbutton
        self.present(menu, animated: true)
    }

    @IBAction func exit(_ sender: Any) {
        if(self.presentingViewController is UserCertificationStepView){
            self.performSegue(withIdentifier: "backToCertification", sender: self)
            ids.sort()
            (self.presentingViewController as! UserCertificationStepView).inputData = ids
        } else {
            self.performSegue(withIdentifier: "back", sender: self)
        }
    }
    func cleanFields(){
        self.name.text = ""
        self.comment.text = ""
        self.added_by.text = ""
    }
    func disableFields(){
        name.isEnabled = false
        comment.isEnabled = false
    }
    
    func enableFields(){
        name.isEnabled = true
        comment.isEnabled = true
    }
    
    func saveData(_ add:Bool = false){
        if(name.text == "" || comment.text == ""){
            let alert = UIAlertController(title: "提示", message: "您的信息还未填写完整，请检查！", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true)
        } else {
            let parameters:Parameters = [
                "id": id,
                "name": name.text ?? "",
                "comment": comment.text ?? ""
            ]
            let headers: HTTPHeaders = [
                "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
            ]
            disableFields()
            Alamofire.request("https://api.nfls.io/club/"+action, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers:headers).responseJSON { response in
                switch(response.result){
                case .success(let json):
                    //print(json)
                    if(self.action == "new"){
                        let info = ((json as! [String:AnyObject])["info"] as! [String:Any])
                        self.id = info["id"] as! Int
                        self.action = "edit"
                    }
                    if(add){
                        self.addData()
                    } else {
                        self.loadData(self.id)
                    }
                    break
                default:
                    break
                }
            }
        }
    }
    
    func loadMessage(_ loadMore:Bool = false){
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/club/intro", method: .get, headers: headers).responseJSON(completionHandler: {
            response in
            switch(response.result){
            case .success(let json):
                let info = ((json as! [String:Any])["info"] as! String).replacingOccurrences(of: "<br/>", with: "\n")
                let notice = UIAlertController(title: "填写提示", message: info, preferredStyle: .alert)
                (notice.view.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[1] as! UILabel).textAlignment = .left
                let ok = UIAlertAction(title: "我知道了", style: .default, handler: {
                    action in
                    if(loadMore){
                        self.prepareList()
                    }
                })
                notice.addAction(ok)
                self.present(notice, animated: true)
                break
            default:
                break
            }
        })

    }
    
    func addData(){
        disableFields()
        selected.append(id)
        selected = Array(Set(selected))
        id = 0
        prepareList()
        cleanFields()
    }
    
    func prepareList(){
        self.names.removeAll()
        self.ids.removeAll()
        self.tableview.reloadData()
        for id in selected {
            addData(id)
        }
        if(selected.isEmpty){
            self.performSegue(withIdentifier: "showTableSelect2", sender: "club")
        }
    }
    func loadData(_ id:Int){
        let parameters:Parameters = [
            "id":id
        ]
        Alamofire.request("https://api.nfls.io/club/get", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            switch(response.result){
            case .success(let json):
                let info = ((json as! [String:AnyObject])["info"] as! [String:Any])
                self.name.text = info["name"] as? String
                self.comment.text = info["comment"] as? String
                self.added_by.text = info["added_by"] as? String
                self.enableFields()
                break
            default:
                break
            }
        }
    }
    func addData(_ id:Int){
        let parameters:Parameters = [
            "id":id
        ]
        
        Alamofire.request("https://api.nfls.io/club/get", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            switch(response.result){
            case .success(let json):
                
                let info = ((json as! [String:AnyObject])["info"] as! [String:Any])
                self.names.append(info["name"] as! String)
                self.ids.append(info["id"] as! Int)
                DispatchQueue.main.async {
                    self.tableview.reloadData()
                }
                break
            default:
                break
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ID, for: indexPath as IndexPath)
        cell.textLabel!.text = names[indexPath.row]
        cell.sizeToFit()
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        names.remove(at: indexPath.row)
        ids.remove(at: indexPath.row)
        selected = ids
        prepareList()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "showTableSelect2" {
            if let destinationVC = segue.destination as? TableSelectViewController {
                destinationVC.type = sender as! String
            }
        }
    }
    @IBAction func backToClubView(segue: UIStoryboardSegue){
        
    }
}
