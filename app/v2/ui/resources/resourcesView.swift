//
//  resourcesView.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 18/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import AliyunOSSiOS
import Alamofire
import SwiftyJSON
import FileKit
import QuickLook
import SCLAlertView
import SafariServices
import Cache

class ResourcesViewController:UITableViewController {
    
    var cacheMode = false
    var multiMode = false
    
    var cacheButton = UIBarButtonItem()
    var multiButton = UIBarButtonItem()
    var downloadButton = UIBarButtonItem()
    var previewButton = UIBarButtonItem()
    var deleteButton = UIBarButtonItem()
    
    let provider = SchoolProvider()
    
    var files = [File]()
    
    override func viewDidLoad() {
        self.cacheButton = UIBarButtonItem(title: "缓存", style: .plain, target: self, action: #selector(cache))
        self.multiButton = UIBarButtonItem(title: "多选", style: .plain, target: self, action: #selector(multi))
        self.downloadButton = UIBarButtonItem(title: "下载", style: .plain, target: self, action: #selector(bulk))
        self.previewButton = UIBarButtonItem(title: "预览", style: .plain, target: self, action: #selector(bulkView))
        self.deleteButton = UIBarButtonItem(title: "删除", style: .plain, target: self, action: #selector(bulkDelete))
        
        self.reloadData()
        
        definesPresentationContext = true
       
    }
    
    @objc func multi(sender:UIButton){
        multiMode = !multiMode
        sender.isSelected = multiMode
    }
    
    @objc func cache(sender:UIButton){
        cacheMode = !cacheMode
        sender.isSelected = cacheMode
    }
    
    @objc func bulk(sender:UIButton){
        
    }
    
    @objc func bulkView(sender:UIButton){
        
    }
    
    @objc func bulkDelete(sender:UIButton){
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    func goBack(){
        provider.path.removeLast()
        self.reloadData()
    }
    func goToFolder(withFileName file:String){
        provider.path.append(file)
        self.reloadData()
    }
    func reloadData() {
        provider.getFileList(completion: refresh(_:))
    }
    func refresh(_ files:[File]){
        dump(files)
        self.files = files
        if(multiMode){
            if(!cacheMode){
                self.navigationItem.rightBarButtonItems = [multiButton,cacheButton,downloadButton,previewButton]
            }else{
                self.navigationItem.rightBarButtonItems = [multiButton,cacheButton,deleteButton,previewButton]
            }
            self.title = nil
        } else {
            self.navigationItem.rightBarButtonItems = [multiButton,cacheButton]
            self.title = "往卷"
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    /*
    func download(_ filename:String){
        
    }
     */
    func preview(_ filename:String){
        /*
        previewController.file = (Path.userDocuments + Path(getCurrentPath()) + filename).url
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(self.previewController, animated: true)
        }
         */
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "aa")
        cell.textLabel?.text = files[indexPath.row].filename
        cell.detailTextLabel?.text = String(describing: files[indexPath.row].size)
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        if(self.multiMode){
            if (cell.accessoryType == .checkmark) {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .checkmark
            }
        }else{
            if(files[indexPath.row].size == 0){
                goToFolder(withFileName: files[indexPath.row].filename)
            }else{
                //download([indexPath.row].filename)
            }
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
        
    }
}
class PreviewController:QLPreviewController, QLPreviewControllerDelegate, QLPreviewControllerDataSource{
    var file:URL? = nil
    
    override func viewDidLoad() {
        self.dataSource = self
        self.delegate = self
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return file as! NSURL
    }
    
}
