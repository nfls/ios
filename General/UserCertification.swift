//
//  UserCertification.swift
//  NFLSers-iOS
//
//  Created by 胡清阳 on 08/06/2017.
//  Copyright © 2017 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class UserCertificationView:UIViewController,UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var enterButton: UIButton!
    var statusData = [String:String]()
    let ID = "cell"
    override func viewDidLoad() {
        tableview.register(DetailCell.self, forCellReuseIdentifier: ID)
        enterButton.isEnabled = false
        checkVersion()
    }
    func checkVersion(){
        let parameters:Parameters = [
            "version":Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        ]
        print(Bundle.main.infoDictionary!["CFBundleShortVersionString"]!)
        Alamofire.request("https://api.nfls.io/device/auth", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: {
            response in
            //dump(response)
            switch(response.result){
            case .success(let json):
                let code = (json as! [String:Int])["code"]
                //print(code)
                if(code == 200){
                    self.enterButton.isEnabled = true
                    self.loadData()
                } else {
                    let alert = UIAlertController(title: "错误", message: "联网检测本地认证数据库版本失败！请尝试将App升级至最新版本后再试。", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "好的", style: .default, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true)
                }
            default:
                break
            }
            
        })
    }
    func loadData(){
        statusData.removeAll()
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/alumni/auth/status", headers: headers).responseJSON { response in
            switch(response.result){
            case .success(let json):
                if((json as! [String:AnyObject])["code"] as! Int) == 200 {
                    let info = ((json as! [String:AnyObject])["message"]! as! [[String:String]])
                    for status in info{
                        self.statusData[status["title"]!] = status["content"]!
                    }
                    self.tableview.delegate = self
                    self.tableview.dataSource = self
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
        let key = Array(statusData.keys)[indexPath.row]
        let value = Array(statusData.values)[indexPath.row]
        cell.textLabel!.text = key
        cell.detailTextLabel!.text = value
        cell.detailTextLabel!.lineBreakMode = .byWordWrapping
        cell.detailTextLabel!.numberOfLines = 0
        cell.detailTextLabel!.sizeToFit()
        cell.sizeToFit()
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statusData.count
    }
    @IBAction func backToAlumni(segue: UIStoryboardSegue){
        
    }
}
