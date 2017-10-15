//
//  WeatherView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/7/6.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class WeatherViewController:UIViewController,UITableViewDataSource,UITableViewDelegate{
    let ID = "Cell"
    var totalStations = 1
    var stationNames : [String] = ["综合信息"]
    var weatherData = [[[String:String]]]()
    
    @IBOutlet weak var tableview: UITableView!
    override func viewDidAppear(_ animated: Bool) {
        tableview.register(DetailCell.self, forCellReuseIdentifier: ID)
        getStationList()
        
    }
    
    func getStationList(){
        let headers: HTTPHeaders = [:
            //"Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/weather/list", headers: headers).responseJSON { response in
            switch(response.result){
            case .success(let json):
                self.weatherData.removeAll()
                self.weatherData.append([["name":"n/a","value":"n/a"]])
                let messages = (json as! [String:AnyObject])["info"] as! [AnyObject]
                for message in messages {
                    let info = message as! [String:Any]
                    self.stationNames.append(info["name"] as! String)
                    self.totalStations += 1
                    self.getStationInfo(id: info["id"] as! Int, update: messages.last?["name"] as! String == message["name"] as! String)
                }
            default:
                break
            }
        }
    }
    
    func getStationInfo(id:Int,update:Bool = false){
        let parameters:Parameters = [
            "id":String(id)
        ]
        Alamofire.request("https://api.nfls.io/weather/data", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            dump(response)
            switch(response.result){
            case .success(let json):
                let messages = (json as! [String:AnyObject])["info"] as! [AnyObject]
                dump(messages)
                var whole = [[String:String]]()
                var data = [String:String]()
                for message in messages {
                    let info = message as! [String:Any]
                    var name = info["name"] as! String
                    if((info["sensor_name"] as? String) != nil && (info["sensor_name"] as? String) != ""){
                        name = name + " [" + (info["sensor_name"] as! String) + "]"
                    }
                    var value = String(info["value"] as! Double)
                    if((info["unit"] as? String) != nil && (info["unit"] as? String) != ""){
                        value = value + " " + (info["unit"] as! String)
                    }
                    data["name"] = name
                    data["value"] = value
                    whole.append(data);
                }
                self.weatherData.append(whole)
                if(update){
                    DispatchQueue.main.async {
                        self.tableview.dataSource = self
                        self.tableview.delegate = self
                        self.tableview.reloadData()
                    }
                }
            default:
                break
            }
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: ID, for: indexPath as IndexPath)
        let key = weatherData[indexPath.section][indexPath.row]["name"]
        let value = weatherData[indexPath.section][indexPath.row]["value"]
        cell.textLabel!.text = key
        cell.detailTextLabel!.text = value
        cell.detailTextLabel!.lineBreakMode = .byWordWrapping
        cell.detailTextLabel!.numberOfLines = 0
        cell.detailTextLabel!.sizeToFit()
        cell.sizeToFit()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return stationNames[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return totalStations
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return 
    }
    
}
class DetailCell:UITableViewCell{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        //self.setUpUI()
    }
}
