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
import IGListKit
import AVFoundation

class PhotoCell: UITableViewCell {
    @IBOutlet weak var photo: UIImageView!
    public func setImage(_ image: UIImage) {
        photo?.image = image
        photo?.frame = AVMakeRect(aspectRatio: image.size, insideRect: photo.frame)
    }
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
        SDWebImageManager.shared().loadImage(with: current[indexPath.row].hdUrl, options: SDWebImageOptions.highPriority, progress: nil) { (image, _, _, _, _, _) in
            DispatchQueue.main.async {
                cell.setImage(image!)

            }
        }
        return cell
    }
}
