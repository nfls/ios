//
//  AlumniActivityView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/8/18.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class AlumniActivityViewController:UIViewController,UITableViewDelegate,UITableViewDataSource{
    let ID = "cell"
    var data = [[String:Any]]()
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        tableview.register(DownloadCell.self, forCellReuseIdentifier: ID)
        getData()
    }
    func getData(){
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/alumni/post/list", headers: headers).responseJSON{ response in
            switch response.result{
            case .success(let json):
                //dump(json)
                if(((json as! [String:AnyObject])["code"] as! Int)==200){
                    let messages = (json as! [String:AnyObject])["info"] as! [[String:Any]]
                    var str = [String:Any]()
                    for message in messages {
                        str["title"] = message["title"]
                        let date = Date(timeIntervalSince1970: (TimeInterval(message["modified"] as! Int)))
                        let dateformatter = DateFormatter()
                        dateformatter.dateFormat = "yyyy-MM-dd HH:mm"
                        str["subtitle"] = dateformatter.string(from: date)
                        str["cid"] = message["cid"]
                        self.data.append(str)
                    }
                    DispatchQueue.main.async{
                        self.tableview.dataSource = self
                        self.tableview.delegate = self
                        self.tableview.reloadData()
                    }
                }
                break
            default:
                break
                /*
                 self.showAlert(false)
                 break
                 */
            }
        }

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ID, for: indexPath as IndexPath)
        cell.textLabel!.text = data[indexPath.row]["title"] as? String
        cell.detailTextLabel!.text = data[indexPath.row]["subtitle"] as? String
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: ID, for: indexPath as IndexPath)
        cell.isSelected = false
        //print(11)
        performSegue(withIdentifier: "showPost", sender: data[indexPath.row]["cid"] as Any)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showPost") {
            //print(111)
            let secondViewController = segue.destination as! PostDetailViewController
            let cid = sender as! Int
            secondViewController.cid = cid
        }
    }

}
