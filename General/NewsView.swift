//
//  NewsView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/10/4.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import Alamofire
import FrostedSidebar

class NewsCell:UITableViewCell{
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var subtitle: UILabel!
}
class NewsViewController:UITableViewController{

    var names = [String]()
    var subtitles = [String]()
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
        
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/center/news",headers: headers).responseJSON { response in
            switch(response.result){
            case .success(let json):
                
                let info = ((json as! [String:AnyObject])["info"] as! [[String:Any]])
                for detail in info {
                    self.names.append(detail["title"] as! String)
                    self.subtitles.append((detail["type"] as! String) + " " + (detail["time"] as! String))
                    self.descriptions.append(detail["detail"] as! String)
                    self.urls.append(detail["conf"] as? String ?? "")
                    self.images.append(detail["img"] as! String)
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
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "news"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "info", for: indexPath) as! NewsCell
        cell.cellTitle.text = names[indexPath.row]
        cell.subtitle.text = subtitles[indexPath.row]
        cell.detail.text = descriptions[indexPath.row]
        cell.myImage.image = UIImage(data: pictures[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        (navigationController?.viewControllers[(navigationController?.viewControllers.count)! - 2] as! HomeScreenController).handleUrl = urls[indexPath.row]
        navigationController?.popViewController(animated: true)
    }

}
