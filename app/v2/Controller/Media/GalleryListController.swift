//
//  GalleryListController.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 21/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import SDWebImage

class AlbumCell: UITableViewCell {
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
}

class GalleryListController: UITableViewController {
    let provider = GalleryProvider()
    override func viewDidLoad() {
        provider.getList {
            self.tableView.reloadData()
            /*Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { (_) in
                self.tableView.reloadData()
            })*/
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
        cell.title!.text = provider.list[indexPath.row].title
        let description = provider.list[indexPath.row].description
        if description != "" {
            cell.subtitle!.text = provider.list[indexPath.row].description
        } else {
            cell.subtitle!.isHidden = true
        }
        let imageView = cell.cover!
        imageView.sd_setImage(with: provider.list[indexPath.row].cover?.hdUrl, completed: nil)
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
