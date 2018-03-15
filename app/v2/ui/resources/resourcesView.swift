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
import SVProgressHUD

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
        tableView.allowsMultipleSelection = multiMode
    }
    
    
    @objc func bulkDownload(sender:UIButton?){
        self.tableView.isUserInteractionEnabled = false
        provider.getFiles(files: self.getSelectedFiles(), progress: { (total, current, file) in
            DispatchQueue.main.async {
                SVProgressHUD.showProgress(Float(current)/Float(total), status: "第\(current)个，共\(total)个。当前为\(file.filename)")
            }
        }, fileProgress: { _ in }) { status in
            DispatchQueue.main.async {
                self.tableView.isUserInteractionEnabled = true
                SVProgressHUD.dismiss()
            }
            if(status){
                self.bulkView(sender: nil)
            }
            self.reloadData()
        }
    }
    
    @objc func bulkView(sender:UIButton?){
        previewController.files.removeAll()
        DispatchQueue.main.async {
            for file in self.getSelectedFiles() {
                self.previewController.files.append((Path.userDocuments + "download" + file.name).url)
            }
            self.previewController.reloadData()
            self.navigationController?.pushViewController(self.previewController, animated: true)
        }
    }
    
    @objc func bulkDelete(sender:UIButton?){
        for file in self.getSelectedFiles() {
            try? FileManager.default.removeItem(at:(Path.userDocuments + "download" + file.name).url)
        }
        self.reloadData()
    }
    
    func getSelectedFiles() -> [File] {
        var files = [File]()
        if let indexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in indexPaths {
                files.append(self.files[indexPath.row])
            }
        }
        return files
        
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
        self.files = files
        self.navigationItem.prompt = "/" + (provider.path as NSArray).componentsJoined(by: "/")
        if(multiMode){
            self.navigationItem.rightBarButtonItems = [multiButton,deleteButton,downloadButton,previewButton]
            self.title = nil
        } else {
            self.navigationItem.rightBarButtonItems = [multiButton]
            self.title = "往卷"
        }
        if(provider.path.count > 0){
            self.navigationItem.hidesBackButton = true
        }else{
            self.navigationItem.hidesBackButton = false
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func calculateSize(bytes:Double) -> String {
        var size = bytes / 1024
        var count = 0
        while (size > 1024) {
            size = size / 1024.0
            count += 1
        }
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
        previewController.files.removeAll()
        previewController.files = [(Path.userDocuments + "download" + file.name).url]
        DispatchQueue.main.async {
            self.previewController.reloadData()
            self.navigationController?.pushViewController(self.previewController, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "aa")
        cell.textLabel?.text = files[indexPath.row].filename
        
        if let size = files[indexPath.row].size {
            if(size != 0){
                if(self.exist(files[indexPath.row])){
                    cell.detailTextLabel?.text = "已缓存(" + self.calculateSize(bytes: files[indexPath.row].size!) + ")"
                } else {
                    cell.detailTextLabel?.text = self.calculateSize(bytes: files[indexPath.row].size!)
                }
            } else {
                cell.detailTextLabel?.text = "文件夹"
            }
        }
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if(!tableView.allowsMultipleSelection){
            return indexPath
        }else if(files[indexPath.row].name.first == "@"){
            return nil
        }else{
            return indexPath
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        if(self.multiMode){
            cell.accessoryType = .none
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        if(self.multiMode){
            cell.accessoryType = .checkmark
        }else{
            if(self.handleSpecialAction(file: files[indexPath.row])) {
  
            }else if(files[indexPath.row].size == 0){
                goToFolder(withFileName: files[indexPath.row].filename)
            }else{
                if(self.exist(files[indexPath.row])){
                    preview(files[indexPath.row])
                } else {
                    self.tableView.isUserInteractionEnabled = false
                    self.provider.getFile(file: files[indexPath.row], progress: { progress in
                        DispatchQueue.main.async {
                            SVProgressHUD.showProgress(Float(progress), status: self.files[indexPath.row].filename)
                        }
                    }) { status in
                        DispatchQueue.main.async {
                            self.tableView.isUserInteractionEnabled = true
                            SVProgressHUD.dismiss()
                        }
                        if(status) {
                            self.preview(self.files[indexPath.row])
                        }
                        self.reloadData()
                    }
                }
                
            }
        }
    }
    func handleSpecialAction(file:File) -> Bool{
        switch file.name {
        case "@Back":
            self.provider.path.removeLast()
            self.reloadData()
            return true
        default:
            return false
        }
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
}
class PreviewController:QLPreviewController, QLPreviewControllerDelegate, QLPreviewControllerDataSource{
    var files = [URL]()
    
    override func viewDidLoad() {
        self.dataSource = self
        self.delegate = self
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return files.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return files[index] as NSURL
    }
    
}
