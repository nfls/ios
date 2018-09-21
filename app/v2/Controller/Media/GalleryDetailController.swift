//
//  GalleryDetailController.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/9/21.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import SDWebImage
import Alamofire
import QuickLook

class PhotoCell: UITableViewCell {
    @IBOutlet weak var photo: UIImageView?
}

class GalleryDetailController: UITableViewController {
    var gallery: Gallery? = nil
    var current: [Photo] {
        get {
            if let gallery = self.gallery {
                return gallery.photos!.filter({ (photo) -> Bool in
                    return photo.originUrl != nil || !isOriginal
                })
            } else {
                return []
            }
        }
    }
    var isOriginal = true
    
    override func viewDidLoad() {
        self.title = gallery?.title
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return current.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PhotoCell
        cell.photo?.sd_setImage(with: current[indexPath.row].hdUrl, completed: nil)
        return cell
    }
}
