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
    var weatherData = [[String:String]]()
    
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
                self.weatherData.append(["n/a":"n/a"])
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
        dump(id)
        let headers: HTTPHeaders = [:
            //"Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        let parameters:Parameters = [
            "id":String(id)
        ]
        Alamofire.request("https://api.nfls.io/weather/data", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            dump(response)
            switch(response.result){
            case .success(let json):
                let messages = (json as! [String:AnyObject])["info"] as! [AnyObject]
                dump(messages)
                var data = [String:String]()
                for message in messages {
                    let info = message as! [String:Any]
                    data[info["name"] as! String] = String(info["value"] as! Double)
                }
                self.weatherData.append(data);
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
        let key = Array(weatherData[indexPath.section].keys)[indexPath.row]
        let value = Array(weatherData[indexPath.section].values)[indexPath.row]
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
    /*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        //let cell = tableView.dequeueReusableCell(withIdentifier: ID)
        //return cell!.textLabel!.frame.height + cell!.detailTextLabel!.frame.height
        return 100
    }
    */
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
