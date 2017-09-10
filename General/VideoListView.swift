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

class VideoListViewController:UIViewController,UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var tableview: UITableView!
    var list = [[String:String]]()
    var exist = [Bool]()
    let ID = "Cell"
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: ID)
        loadData()
    }
    func loadData(){
        Alamofire.request("https://api.nfls.io/video/list").responseJSON { response in
            switch(response.result){
            case .success(let json):
                self.list.removeAll()
                let messages = json as! [[String:Any]]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                for message in messages {
                    var str = [String:String]()
                    let date = dateFormatter.date(from: (message["time"] as! String + " GMT+08:00"))
                    str["date"] = displayFormatter.string(from: date!)
                    str["name"] = (message["name"] as! String)
                    str["url"] = "https://www.bilibili.com/video/" + (message["avid"] as! String)
                    str["uploader"] = (message["uploader"] as! String)
                    self.list.append(str)
                }
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
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: ID, for: indexPath as IndexPath)
        cell.textLabel!.text = list[indexPath.row]["name"]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.isSelected = false
        let openController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        openController.title = "视频详情"
        openController.message = "UP主：" + list[indexPath.row]["uploader"]!
        openController.message! += "\n上传时间：" + list[indexPath.row]["name"]!
        (openController.view.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[1] as! UILabel).textAlignment = .left
        (openController.view.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[1] as! UILabel).numberOfLines = 0
        let okAction = UIAlertAction(title: "好的", style: .cancel, handler: nil)
        openController.addAction(okAction)
        openController.popoverPresentationController?.sourceView = tableView
        openController.popoverPresentationController?.sourceRect = cell.frame
        
        if let url = list[indexPath.row]["url"]{
            let gotoAction = UIAlertAction(title: "B站观看", style: .default, handler: {
                action in
                print(url)
                UIApplication.shared.openURL(NSURL(string:url)! as URL)
            })
            openController.addAction(gotoAction)
            
        }
        self.present(openController, animated: true)
        
    }
    
    
}

