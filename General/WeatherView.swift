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
    struct Station{
        var name:String
        var longitude:Double
        var latitude:Double
        var altitude:Double
        var isOnline:Bool
        var lastUpdate:String
        var data = [[String:String]]()
        init(name:String,longitude:Double,latitude:Double,altitude:Double,isOnline:Bool,lastUpdate:String) {
            self.name = name
            self.longitude = longitude
            self.latitude = latitude
            self.altitude = altitude
            self.isOnline = isOnline
            self.lastUpdate = lastUpdate
        }
    }
    var stations = [Station]()
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
                self.stations.removeAll()
                let messages = (json as! [String:AnyObject])["info"] as! [AnyObject]
                for message in messages {
                    let info = message as! [String:Any]
                    let name = info["name"] as! String
                    let lastUpdate = info["lastUpdate"] as? String ?? ""
                    let isOnline = info["isOnline"] as! Bool
                    let longitude = info["longitude"] as! Double
                    let latitude = info["latitude"] as! Double
                    let altitude = info["altitude"] as! Double
                    self.stations.append(Station(name: name, longitude: longitude, latitude: latitude, altitude: altitude, isOnline: isOnline, lastUpdate: lastUpdate))
                    self.getStationInfo(id: info["id"] as! Int, update: messages.last?["name"] as! String == message["name"] as! String)
                }
            default:
                break
            }
        }
    }
    
    func getStationInfo(id:Int,update:Bool = false){
        let index = stations.count - 1
        let parameters:Parameters = [
            "id":String(id)
        ]
        Alamofire.request("https://api.nfls.io/weather/data", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            switch(response.result){
            case .success(let json):
                let messages = (json as! [String:AnyObject])["info"] as! [AnyObject]
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
                self.stations[index].data = whole
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
        return stations[section].data.count + 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        var key:String?
        var value:String?
        let cell = tableView.dequeueReusableCell(withIdentifier: ID, for: indexPath as IndexPath)
        switch(indexPath.row){
        case 0:
            key = "最近更新时间"
            value = stations[indexPath.section].lastUpdate
        case 1:
            key = "经度"
            value = String(stations[indexPath.section].longitude)
            cell.accessoryType = .disclosureIndicator
        case 2:
            key = "纬度"
            value = String(stations[indexPath.section].latitude)
            cell.accessoryType = .disclosureIndicator
        case 3:
            key = "高度"
            value = String(stations[indexPath.section].altitude) + "m"
            cell.accessoryType = .disclosureIndicator
        default:
            key = stations[indexPath.section].data[indexPath.row - 4]["name"]
            value = stations[indexPath.section].data[indexPath.row - 4]["value"]
        }
        
        cell.textLabel!.text = key
        cell.detailTextLabel!.text = value
        cell.detailTextLabel!.lineBreakMode = .byWordWrapping
        cell.detailTextLabel!.numberOfLines = 0
        cell.detailTextLabel!.sizeToFit()
        cell.sizeToFit()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return stations[section].name
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return stations.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.row){
        case 1,2,3:
            let longitude = stations[indexPath.section].longitude
            let latitude = stations[indexPath.section].latitude
            self.performSegue(withIdentifier: "showMap", sender: [longitude,latitude])
        default:
            break
        }
        return 
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! MapViewController
        let data = sender as! [Double]
        vc.longitude = data[0]
        vc.latitude = data[1]
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
