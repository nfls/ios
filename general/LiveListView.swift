//
//  LiveListView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/8/17.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class LiveListViewController:UIViewController,UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var baritem: UIBarButtonItem!
    @IBOutlet weak var tableview: UITableView!
    var list = [[[String:String]]]()
    var exist = [Bool]()
    let ID = "Cell"
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: ID)
        loadData()
    }
    func loadData(){
        Alamofire.request("https://api.nfls.io/live/list").responseJSON { response in
            switch(response.result){
            case .success(let json):
                self.list.removeAll()
                let messages = json as! [[String:Any]]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let titleFormatter = DateFormatter()
                titleFormatter.dateFormat = "M月d日"
                var current = [[String:String]]()
                var next = [[String:String]]()
                var past = [[String:String]]()
                for message in messages {
                    var str = [String:String]()
                    let currentDate = Date()
                    let startDate = dateFormatter.date(from: (message["start"] as! String + " GMT+08:00"))
                    let endDate = dateFormatter.date(from: (message["end"] as! String + " GMT+08:00"))
                    str["name"] = titleFormatter.string(from: startDate!) + " - " + (message["name"] as! String)
                    str["oriName"] = (message["name"] as! String)
                    str["startTime"] = displayFormatter.string(from: startDate!)
                    str["endTime"] = displayFormatter.string(from: endDate!)
                    str["stream_code"] = (message["stream_code"] as! String)
                    do{
                        let replay = try JSONSerialization.jsonObject(with: (message["replay_url"] as! String).data(using: .utf8)!) as? [String: String]
                        if(replay!["type"]! == "bilibili"){
                            str["url"] = "https://www.bilibili.com/video/" + replay!["id"]!
                        } else {
                            str["url"] = replay!["url"]!
                        }

                    } catch {
                        str["url"] = nil
                    }
                    
                if(currentDate<startDate!){
                        next.append(str)
                    } else if (currentDate>startDate! && currentDate<endDate!){
                        current.append(str)
                    } else {
                        past.append(str)
                    }
                }
                var t = [String:String]()
                t["name"] = "无"
                if(current.isEmpty){
                    self.exist.append(false)
                    current.append(t)
                } else {
                    self.exist.append(true)
                }
                if(next.isEmpty){
                    self.exist.append(false)
                    next.append(t)
                } else {
                    self.exist.append(true)
                }
                self.exist.append(true)
                self.list.append(current)
                self.list.append(next)
                self.list.append(past)
                DispatchQueue.main.async {
                    self.tableview.dataSource = self
                    self.tableview.delegate = self
                    self.tableview.reloadData()
                }
            default:
                break
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: ID, for: indexPath as IndexPath)
        //let key = Array(weatherData[indexPath.section].keys)[indexPath.row]
        //let value = Array(weatherData[indexPath.section].values)[indexPath.row]
        cell.textLabel!.text = list[indexPath.section][indexPath.row]["name"]
        //cell.detailTextLabel!.text = "a"
        //cell.detailTextLabel!.lineBreakMode = .byWordWrapping
        //cell.detailTextLabel!.numberOfLines = 0
        //cell.detailTextLabel!.sizeToFit()
        //cell.sizeToFit()
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0:
            return "正在进行的"
        case 1:
            return "即将开始的"
        case 2:
            return "已经结束的"
        default:
            break
        }
        return ""
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.isSelected = false
        let openController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if(exist[indexPath.section]){
            openController.title = "直播详情"
            openController.message = "直播名称：" + list[indexPath.section][indexPath.row]["oriName"]!
            openController.message! += "\n开始时间：" + list[indexPath.section][indexPath.row]["startTime"]!
            openController.message! += "\n结束时间：" + list[indexPath.section][indexPath.row]["endTime"]!
            (openController.view.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[1] as! UILabel).textAlignment = .left
            (openController.view.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[1] as! UILabel).numberOfLines = 0
            let okAction = UIAlertAction(title: "好的", style: .cancel, handler: nil)
            openController.addAction(okAction)
            openController.popoverPresentationController?.sourceView = tableView
            openController.popoverPresentationController?.sourceRect = cell.frame
            switch(indexPath.section){
            case 0:
                if(list[indexPath.section][indexPath.row]["stream_code"]!.hasPrefix("http")){
                    let gotoAction = UIAlertAction(title: "观看", style: .default, handler: {
                        action in
                            UIApplication.shared.openURL(NSURL(string:self.list[indexPath.section][indexPath.row]["stream_code"]!)! as URL)
                    })
                    openController.addAction(gotoAction)
                }
                
            case 1:
                break
            case 2:
            if let url = list[indexPath.section][indexPath.row]["url"]{
                    let gotoAction = UIAlertAction(title: "回放", style: .default, handler: {
                        action in
                        print(url)
                        UIApplication.shared.openURL(NSURL(string:url)! as URL)
                    })
                    openController.addAction(gotoAction)
                }
                break
            default:
                break
                
                
            }
            self.present(openController, animated: true)

        }
    }
    

}
