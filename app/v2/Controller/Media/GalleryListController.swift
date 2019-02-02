//
//  GalleryListController.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 21/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import SDWebImage
import AVFoundation

class AlbumCell: UITableViewCell {
    @IBOutlet weak var cover: ScaledHeightImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    final func setImage(image: UIImage) {
        cover?.image = image
        cover?.frame = AVMakeRect(aspectRatio: image.size, insideRect: cover.frame)
        self.layoutIfNeeded()
    }
}

class GalleryListController: UITableViewController {
    let provider = GalleryProvider()
    override func viewDidLoad() {
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 200
        provider.getList {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return provider.list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AlbumCell
        SDWebImageManager.shared().loadImage(with: provider.list[indexPath.row].cover?.hdUrl, options: SDWebImageOptions.highPriority, progress: nil) { (image, _, _, _, _, _) in
            DispatchQueue.main.async {
                cell.setImage(image: image!)
            }
        }
        cell.title!.text = provider.list[indexPath.row].title
        let description = provider.list[indexPath.row].description
        if description != "" {
            cell.subtitle!.text = provider.list[indexPath.row].description
        } else {
            cell.subtitle!.isHidden = true
        }
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.provider.getDetail(id: provider.list[indexPath.row].id) {
            self.performSegue(withIdentifier: "showDetail", sender: self.provider.detail)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! GalleryDetailController
        viewController.gallery = (sender as! Gallery)
    }
}
