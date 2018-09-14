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
    
    var headerButton = UIBarButtonItem()
    var multiButton = UIBarButtonItem()
    var downloadButton = UIBarButtonItem()
    var deleteButton = UIBarButtonItem()
    
    let provider = ResourceProvider()
    
    var files = [File(specialAction: "none", withName: "加载中，大概需要1分钟。"), File(specialAction: "none", withName: "如果长期卡住，请检查实名认证是否完成"),File(specialAction: "none", withName: "以及邮箱和手机是否完成绑定！")]
    
    var swipe = UIScreenEdgePanGestureRecognizer()
    
    override var navigationItem: UINavigationItem {
        return self.tabBarController!.navigationItem
    }
    
    override var navigationController: UINavigationController? {
        return self.tabBarController!.navigationController
    }
    
    override func viewDidLoad() {
        self.multiButton = UIBarButtonItem(title: "多选", style: .plain, target: self, action: #selector(multi))
        self.downloadButton = UIBarButtonItem(title: "查看", style: .plain, target: self, action: #selector(bulkDownload))
        self.deleteButton = UIBarButtonItem(title: "删除", style: .plain, target: self, action: #selector(bulkDelete))
        self.headerButton = UIBarButtonItem(title: "提示", style: .plain, target: self, action: #selector(loadHeader))
        
        self.reloadData()
        self.swipe = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(goBack))
        self.swipe.edges = .left
        self.swipe.delegate = self
        definesPresentationContext = true
        self.provider.getAnnouncement {
            self.loadHeader()
        }
        view.addGestureRecognizer(swipe)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.prompt = nil
        //self.navigationItem.rightBarButtonItems = []
    }
    
    @objc func loadHeader() {
        let storyboard = UIStoryboard(name: "Main_v2", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AnnouncementViewController") as! AnnouncementViewController
        controller.text = self.provider.announcement
        controller.title = "资源下载中心提示"
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc func multi(sender:UIButton){
        multiMode = !multiMode
        self.reloadData()
        sender.isSelected = multiMode
        tableView.allowsMultipleSelection = multiMode
    }
    
    
    @objc func bulkDownload(sender:UIButton?){
        self.tableView.isUserInteractionEnabled = false
        bulkDownloadAction(files: self.getSelectedFiles())
    }
    
    func bulkDownloadAction(files:[File]) {
        provider.getFiles(files:self.filterOut(files: files), progress: { (total, current, file) in
            DispatchQueue.main.async {
                SVProgressHUD.showProgress(Float(current)/Float(total), status: "第\(current)个，共\(total)个。当前为\(file.filename)")
            }
        }, fileProgress: { _ in }) { status in
            DispatchQueue.main.async {
                self.tableView.isUserInteractionEnabled = true
                SVProgressHUD.dismiss()
            }
            if(status){
                self.bulkView(sender: files)
            }
            self.reloadData()
        }
    }
    
    func filterOut(files:[File]) -> [File] {
        return files.filter({ (file) -> Bool in
            return !self.exist(file)
        })
    }
    
    @objc func bulkView(sender:Any?){
        let previewController = PreviewController()
        previewController.files.removeAll()
        DispatchQueue.main.async {
            if let files = sender as? [File] {
                for file in files {
                    previewController.files.append((Path.userDocuments + "download" + file.name).url)
                }
            } else {
                for file in self.getSelectedFiles() {
                    previewController.files.append((Path.userDocuments + "download" + file.name).url)
                }
            }
            previewController.reloadData()
            self.navigationController?.pushViewController(previewController, animated: true)
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadData()
        
    }
    @objc func goBack(){
        if(self.swipe.isEnabled) {
            self.swipe.isEnabled = false
            print("aa")
            provider.path.removeLast()
            self.reloadData()
        }
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
        DispatchQueue.main.async {
            if self.tabBarController?.selectedViewController is ResourcesViewController {
                //self.navigationItem.prompt = "路径: /" + (self.provider.path as NSArray).componentsJoined(by: "/")
                self.navigationItem.rightBarButtonItems = [self.headerButton]
                /*
                if(self.multiMode){
                    self.navigationItem.rightBarButtonItems = [self.headerButton,self.multiButton,self.deleteButton,self.downloadButton]
                } else {
                    self.navigationItem.rightBarButtonItems = [self.headerButton,self.multiButton]
                }
                 */
                if(self.provider.path.count > 0){
                    //self.navigationItem.hidesBackButton = true
                    self.swipe.isEnabled = true
                }else{
                    //self.navigationItem.hidesBackButton = false
                    self.swipe.isEnabled = false
                }
            }

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
        let previewController = PreviewController()
        previewController.files.removeAll()
        previewController.files = [(Path.userDocuments + "download" + file.name).url]
        DispatchQueue.main.async {
            previewController.reloadData()
            self.navigationController?.pushViewController(previewController, animated: true)
        }
    }
    
    func download(_ file: File) {
        if(self.exist(file)){
            preview(file)
        } else {
            self.tableView.isUserInteractionEnabled = false
            let toDownload = checkMarkschemes(file)
            if(toDownload.count == 1 || true) {
                self.provider.getFile(file: file, progress: { progress in
                    DispatchQueue.main.async {
                        SVProgressHUD.showProgress(Float(progress), status: file.filename)
                    }
                }) { status in
                    DispatchQueue.main.async {
                        self.tableView.isUserInteractionEnabled = true
                        SVProgressHUD.dismiss()
                    }
                    if(status) {
                        self.preview(file)
                    }
                    self.reloadData()
                }
            } else {
                self.bulkDownloadAction(files: toDownload)
            }
            
        }
    }
    
    func checkMarkschemes(_ file: File) -> [File]{
        var target: String = "This is rubbish."
        switch file {
        case let file where file.filename.contains("qp"):
            target = file.filename.replacingOccurrences(of: "qp", with: "ms")
        case let file where file.filename.contains("ms"):
            target = file.filename.replacingOccurrences(of: "ms", with: "qp")
        case let file where file.filename.contains("_markscheme.pdf"):
            target = file.filename.replacingOccurrences(of: "_markscheme.pdf", with: ".pdf")
        case let file where file.filename.contains(".pdf"):
            target = file.filename.replacingOccurrences(of: ".pdf", with: "_markscheme.pdf")
        default:
            target = "This is rubbish."
        }
        let filtered = self.files.filter { (file) -> Bool in
            return file.filename == target
        }
        if(filtered.count == 1) {
            return [file, filtered[0]]
        } else {
            return [file]
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
    
    // MARK: UITableView Delegates
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
                download(files[indexPath.row])
            }
        }
    }
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
}

extension ResourcesViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
