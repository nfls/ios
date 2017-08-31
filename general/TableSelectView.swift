//
//  TableSelectView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/8/31.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class TableSelectViewController:UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var tableview: UITableView!
    var type = "university"
    let ID = "Cell"
    var lastName = "顾平德穿女装"
    var names = [String]()
    var ids = [Int]()
    var startWith = 0
    var limit = 30
    override func viewDidLoad() {
        self.tableview.register(UITableViewCell.self, forCellReuseIdentifier: ID)
        self.tableview.dataSource = self
        self.tableview.delegate = self
        self.name.delegate = self
        loadData()
    }
    func loadData(_ name:String = ""){
        var refresh = true
        if(lastName == name){
            startWith += limit
            refresh = false
        } else {
            lastName = name
            startWith = 0
        }
        let parameters:Parameters = [
            "name":name,
            "limit":limit,
            "startFrom":startWith
        ]

        Alamofire.request("https://api.nfls.io/" + type + "/list", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            switch(response.result){
            case .success(let json):
                if(refresh){
                    self.names.removeAll()
                    self.ids.removeAll()
                }
                let rawNames = (((json as! [String:AnyObject])["info"]!) as! [[String:Any]])
                for names in rawNames{
                    self.names.append(names["name"]! as! String)
                    self.ids.append(names["id"]! as! Int)
                }
                DispatchQueue.main.async {
                    self.tableview.reloadData()
                }
            default:
                break
            }
        }

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ID, for: indexPath as IndexPath)
        //let key = Array(weatherData[indexPath.section].keys)[indexPath.row]
        //let value = Array(weatherData[indexPath.section].values)[indexPath.row]
        cell.textLabel!.text = names[indexPath.row]
        cell.sizeToFit()
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.row == names.count - 1){
            loadData(lastName)
        }
    }
    
    @IBAction func editingEnd(_ sender: Any) {
        loadData(name.text!)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if(type == "university"){
            guard let parent = self.presentingViewController else{
                return
            }
            if parent.isKind(of: UniversityInfoViewController.self){
                (parent as! UniversityInfoViewController).id = ids[indexPath.row]
                self.performSegue(withIdentifier: "backToUniversity", sender: self)
            }
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        loadData(name.text!)
        return true
    }
    
}
