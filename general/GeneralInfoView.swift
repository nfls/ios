//
//  GeneralInfoView.swift
//  
//
//  Created by 胡清阳 on 07/06/2017.
//
//

import Foundation
import UIKit
import Alamofire

class GeneralInfoView:UIViewController,UITableViewDataSource,UITableViewDelegate{
    
    
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        getGeneralInformation()
        getWikiInformation()
        getForumInformation()
        tableview.register(DetailCell.self, forCellReuseIdentifier: ID)
        tableview.delegate = self
        tableview.dataSource = self
    }
    var statusData = [String:String]()
    var forumData = [String:String]()
    var wikiData = [String:String]()
    let ID = "cell"
    
    func getGeneralInformation() {
        let headers: HTTPHeaders = [
        "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/center/generalInfo", headers: headers).responseJSON{ response in
            switch response.result{
            case .success(let json):
                if(((json as! [String:AnyObject])["code"] as! Int)==200){
                    let jsonDic = (json as! [String:AnyObject])["info"]!
                    self.statusData["用户ID"] = jsonDic.object(forKey: "id") as? String
                    self.statusData["加入时间"] = jsonDic.object(forKey: "join_time") as? String
                    self.statusData["用户名"] = jsonDic.object(forKey: "username") as? String
                    self.statusData["邮箱"] = jsonDic.object(forKey: "email") as? String
                    self.statusData["头像地址"] = jsonDic.object(forKey: "avatar_path") as? String
                    if(jsonDic.object(forKey: "is_activated") as! Int == 1){
                        self.statusData["激活状态"] = "已激活"
                    } else {
                        self.statusData["激活状态"] = "未激活"
                    }
                    self.tableview.reloadData()
                }
            default:
                break
            }
        }
    }
    
    func getForumInformation() {
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/center/forumInfo", headers: headers).responseJSON{ response in
            switch response.result{
            case .success(let json):
                if(((json as! [String:AnyObject])["code"] as! Int)==200){
                    let jsonDic = (json as! [String:AnyObject])["info"]!
                    self.forumData["ID"] = jsonDic.object(forKey: "id") as? String
                    self.forumData["用户名"] = jsonDic.object(forKey: "username") as? String
                    self.forumData["最近登录"] = jsonDic.object(forKey: "last_seen_time") as? String
                    self.forumData["最近通知阅读"] = jsonDic.object(forKey: "2017-08-24 02:27:23") as? String
                    self.forumData["发帖数"] = jsonDic.object(forKey: "discussions_count") as? String
                    self.forumData["评论数"] = jsonDic.object(forKey: "avatar_path") as? String
                    self.tableview.reloadData()
                }
            default:
                break
            }
        }
    }
    
    func getWikiInformation() {
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/center/forumInfo", headers: headers).responseJSON{ response in
            switch response.result{
            case .success(let json):
                if(((json as! [String:AnyObject])["code"] as! Int)==200){
                    let jsonDic = (json as! [String:AnyObject])["info"]!
                    self.wikiData["ID"] = jsonDic.object(forKey: "user_id") as? String
                    self.wikiData["用户名"] = jsonDic.object(forKey: "user_name") as? String
                    self.wikiData["真实姓名"] = jsonDic.object(forKey: "user_real_name") as? String
                    self.wikiData["注册时间"] = jsonDic.object(forKey: "user_registration") as? String
                    self.wikiData["最近登录"] = jsonDic.object(forKey: "user_touched") as? String
                    self.wikiData["编辑数"] = jsonDic.object(forKey: "user_editcount") as? String
                    self.tableview.reloadData()
                }
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ID, for: indexPath as IndexPath)
        var key:String = ""
        var value:String = ""
        switch(indexPath.section){
        case 0:
            key = Array(statusData.keys)[indexPath.row]
            value = Array(statusData.values)[indexPath.row]
        case 1:
            key = Array(forumData.keys)[indexPath.row]
            value = Array(forumData.values)[indexPath.row]
        case 2:
            key = Array(wikiData.keys)[indexPath.row]
            value = Array(wikiData.values)[indexPath.row]
        default:
            break
        }
        
        cell.textLabel!.text = key
        cell.detailTextLabel!.text = value
        cell.detailTextLabel!.lineBreakMode = .byWordWrapping
        cell.detailTextLabel!.numberOfLines = 0
        cell.detailTextLabel!.sizeToFit()
        cell.sizeToFit()
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section){
        case 0:
            return statusData.count
        case 1:
            return forumData.count
        case 2:
            return wikiData.count
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section){
        case 0:
            return "个人"
        case 1:
            return "论坛"
        case 2:
            return "百科"
        default:
            return ""
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    

}
