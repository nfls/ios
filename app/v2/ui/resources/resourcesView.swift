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
    
    let previewController = PreviewController()
    
    override func viewDidLoad() {
        self.cacheButton = UIBarButtonItem(title: "缓存", style: .plain, target: self, action: #selector(cache))
        self.multiButton = UIBarButtonItem(title: "多选", style: .plain, target: self, action: #selector(multi))
        self.downloadButton = UIBarButtonItem(title: "下载", style: .plain, target: self, action: #selector(bulkDownload))
        self.previewButton = UIBarButtonItem(title: "预览", style: .plain, target: self, action: #selector(bulkView))
        self.deleteButton = UIBarButtonItem(title: "删除", style: .plain, target: self, action: #selector(bulkDelete))
        
        self.reloadData()
        
        definesPresentationContext = true
       
    }
    
    @objc func multi(sender:UIButton){
        multiMode = !multiMode
        self.reloadData()
        sender.isSelected = multiMode
    }
    
    @objc func cache(sender:UIButton){
        cacheMode = !cacheMode
        self.reloadData()
        sender.isSelected = cacheMode
    }
    
    @objc func bulkDownload(sender:UIButton){
        dump(tableView.indexPathsForSelectedRows)
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
    
    func calculateSize(bytes:Double) -> String {
        var size = bytes / 1024
        var count = 0
        repeat{
            size = size / 1024.0
            count += 1
        } while (size > 1024)
        var quantity:String = ""
        switch(count){
        case 0:
            quantity = "KB"
            break
        case 1:
            quantity = "MB"
            break
        case 2:
            quantity = "GB"
            break
        default:
            break
        }
        if(size<0){
            print("Unexpected:")
            print(bytes)
        }
        return String(format: "%.1f", size) + " " + quantity
    }
    
    func exist(_ file:File) -> Bool
    {
        if(file.size == 0) {
            return false
        }
        let path = Path.userDocuments + "download" + file.name
        return path.exists
    }
    
    func preview(_ file:File)
    {
        previewController.file = (Path.userDocuments + "download" + file.name).url
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(self.previewController, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "aa")
        cell.textLabel?.text = files[indexPath.row].filename
        if(self.exist(files[indexPath.row])){
            cell.detailTextLabel?.text = "已缓存"
        } else {
            if let size = files[indexPath.row].size, size != 0{
                cell.detailTextLabel?.text = self.calculateSize(bytes: files[indexPath.row].size!)
            } else {
                cell.detailTextLabel?.text = "文件夹"
            }
            
        }
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
                if(self.exist(files[indexPath.row])){
                    preview(files[indexPath.row])
                } else {
                    self.provider.getFile(file: files[indexPath.row], progress: { progress in
                        print(progress)
                    }) { status in
                        if(status) {
                            self.preview(self.files[indexPath.row])
                        }
                        self.reloadData()
                    }
                }
                
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
