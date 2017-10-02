//
//  GameCenterView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/10/3.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class GameCenterViewController:UITableViewController{
    
    var names = [String]()
    var descriptions = [String]()
    var urls = [String]()
    var images = [String]()
    var pictures = [Data]()
    
    
    func getPictures(index:Int){
        if(index >= images.count){
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            return
        }
        Alamofire.request(images[index]).responseData { (response) in
            switch(response.result){
            case .success(let data):
                self.pictures.append(data)
                self.getPictures(index: index + 1)
                break
            default:
                break
            }
        }
    }
    
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    override func viewDidLoad() {
        Alamofire.request("https://api.nfls.io/game/list").responseJSON { response in
            switch(response.result){
            case .success(let json):
                
                let info = ((json as! [String:AnyObject])["info"] as! [[String:Any]])
                for detail in info {
                    self.names.append(detail["name"] as! String)
                    self.descriptions.append(detail["description"] as! String)
                    self.urls.append(detail["url"] as! String)
                    self.images.append(detail["icon"] as! String)
                }
                self.getPictures(index: 0)
                break
            default:
                break
            }
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ID", for: indexPath)
        
        cell.textLabel?.text = names[indexPath.row]
        cell.detailTextLabel?.text = descriptions[indexPath.row]
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.lineBreakMode = .byWordWrapping
        cell.imageView?.image = imageWithImage(image: UIImage(data: pictures[indexPath.row])!, scaledToSize: CGSize(width: 50, height: 50))
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showGame", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let index = sender as! Int
        let dest = segue.destination as! GameViewController
        dest.location = urls[index]
        dest.name = names[index]
    }
    
}
