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
    let oauth2 = NFLSOAuth2()
    var data = [File]()
    var currentData = [File]()
    var path = [String]()
    let dateFormatter = DateFormatter()
    let stringFormater = DateFormatter()
    var client = OSSClient()
    let previewController = PreviewController()
    let load = UIAlertController(title: "加载中", message: "请稍后", preferredStyle: .alert)
    let progress = UIAlertProgressViewController(title: "", message: "", preferredStyle: .alert)
    var cacheMode = false
    var multiMode = false
    
    var cacheButton = UIBarButtonItem()
    var multiButton = UIBarButtonItem()
    var downloadButton = UIBarButtonItem()
    var previewButton = UIBarButtonItem()
    var deleteButton = UIBarButtonItem()
    
    
    struct File{
        var filename:String
        var time:Date?
        var size:Int?
    }
    override func viewDidLoad() {
        cacheButton = UIBarButtonItem(title: "缓存", style: .plain, target: self, action: #selector(cache))
        multiButton = UIBarButtonItem(title: "多选", style: .plain, target: self, action: #selector(multi))
        downloadButton = UIBarButtonItem(title: "下载", style: .plain, target: self, action: #selector(bulk))
        previewButton = UIBarButtonItem(title: "预览", style: .plain, target: self, action: #selector(bulkView))
        deleteButton = UIBarButtonItem(title: "删除", style: .plain, target: self, action: #selector(bulkDelete))
        
        definesPresentationContext = true
        self.progress.addProgressView()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        stringFormater.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        let req = oauth2.oauth2.request(forURL: URL(string: "https://nfls.io/school/pastpaper/token")!)
        self.present(self.load, animated: true)
        oauth2.oauth2.perform(request: req) { (response) in
            DispatchQueue.main.async {
                self.load.message = "正在与阿里云进行通讯"
            }
            do {
                if let rsp = response.data{
                    let data = try JSON(data: rsp)
                    let provider = OSSStsTokenCredentialProvider(accessKeyId: data["data"]["AccessKeyId"].string!, secretKeyId: data["data"]["AccessKeySecret"].string!, securityToken: data["data"]["SecurityToken"].string!)
                    self.client = OSSClient(endpoint: "https://oss-cn-shanghai.aliyuncs.com", credentialProvider: provider)
                    DispatchQueue.main.async {
                        
                        self.loadData()
                    }
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            } catch _ {
                DispatchQueue.main.async {
                    let error = SCLAlertView()
                    error.addButton("实名认证", action: {
                        DispatchQueue.main.async {
                            self.load.dismiss(animated: true, completion: {
                                let safari = SFSafariViewController(url: URL(string : "https://nfls.io/#/alumni/auth")!)
                                self.present(safari,animated: true)
                            })
                        }
                        
                    })
                    let responder = error.showError("错误", subTitle: "账户未完成实名认证！",closeButtonTitle: "关闭")
                    responder.setDismissBlock {
                        self.load.dismiss(animated: true, completion: nil)
                    }
                }
            }
            
        }
    }
    
    @objc func multi(sender:UIButton){
        multiMode = !multiMode
        self.refresh()
        sender.isSelected = multiMode
    }
    
    @objc func cache(sender:UIButton){
        cacheMode = !cacheMode
        self.refresh()
        sender.isSelected = cacheMode
    }
    
    @objc func bulk(sender:UIButton){
        for indexPath in tableView.indexPathsForSelectedRows! {
            var row = indexPath.row
            if(path.count > 0){
                row -= 1
            }
            var toDownload = [File]()
            toDownload.append(contentsOf: data.filter({ file -> Bool in
                //dump(getCurrentPath() + currentData[row].filename)
                return file.filename.starts(with: getCurrentPath() + currentData[row].filename)
            }))
            //dump(toDownload)
        }
    }
    
    @objc func bulkView(sender:UIButton){
        
    }
    
    @objc func bulkDelete(sender:UIButton){
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refresh()
    }
    @objc func goBack(){
        path.removeLast()
        refresh()
    }
    func loadData(next:String? = nil){
        let bucket = OSSGetBucketRequest()
        bucket.bucketName = "nfls-papers"
        bucket.maxKeys = 1000
        bucket.marker = next ?? ""
        bucket.prefix = ""
        let task = client.getBucket(bucket)
        task.continue({ rsp -> Any? in
            if let t = (rsp.result as? OSSGetBucketResult) {
                if let contents = t.contents {
                    for object in contents{
                        let data = object as! [String:Any]
                        let filename = data["Key"] as! String
                        DispatchQueue.main.async {
                            self.load.message = "正在加载文件列表：" + filename
                        }
                        if let date = data["LastModified"] as? String, let size = data["Size"] as? String {
                            self.data.append(File(filename: filename, time: self.dateFormatter.date(from: date), size: Int(size)))
                        }else{
                            self.data.append(File(filename: filename, time: nil, size: nil))
                        }
                    }
                    
                    self.loadData(next: (t.contents!.last as! [String:Any])["Key"] as? String)
                }else{
                    self.refresh()
                    self.load.dismiss(animated: true, completion: nil)
                }
            } else {
                print(rsp.error)
            }
            return task
        })
    }
    func goToFolder(file:String){
        path.append(file)
        refresh()
    }
    func filterData(){
        currentData = data.filter({ file -> Bool in
            let filename = file.filename
            if(filename.hasSuffix("/")) {
                return (filename.components(separatedBy: "/").count - 1 == path.count + 1) && filename.hasPrefix(getCurrentPath())
            } else {
                return (filename.components(separatedBy: "/").count == path.count + 1) && filename.hasPrefix(getCurrentPath())
            }
        }).map{
            return File(filename: $0.filename.replacingOccurrences(of: getCurrentPath(), with: "").replacingOccurrences(of: "/", with: ""), time: $0.time, size: $0.size)
        }
    }
    func refresh(){
        
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
            self.filterData()
            self.tableView.reloadData()
        }
    }
    func getCurrentPath() -> String{
        var uri = path.reduce(""){
            $0 + "/" + $1
        } + "/"
        if(uri.hasPrefix("/")){
            uri = String(uri.suffix(uri.count - 1))
        }
        //print(uri)
        return uri
    }
    func isExist(_ filename:String) -> Bool {
        let path = Path.userDocuments + Path(getCurrentPath())
        return (path + filename).exists
    }
    
    func download(_ filename:String){
        let request = OSSGetObjectRequest()
        request.bucketName = "nfls-papers"
        request.objectKey = getCurrentPath() + filename
        let path = Path.userDocuments + Path(getCurrentPath())
        if isExist(filename){
            self.preview(filename)
        }else{
            do{
                try path.createDirectory(withIntermediateDirectories: true)
                request.downloadProgress = { bytesWritten, totalBytesWritten, bytesExpectedToWritten in
                    print([bytesWritten,totalBytesWritten,bytesExpectedToWritten])
                    self.progress.setPercentage(Float(Double(totalBytesWritten)/Double(bytesExpectedToWritten)))
                }
                //print(request.downloadToFileURL)
                let task = client.getObject(request)
                task.continue({ task -> Any? in
                    if let error = task.error {
                        self.progress.dismiss(animated: true, completion: nil)
                        print(error)
                    }else{
                        let result = task.result as! OSSGetObjectResult
                        try? result.downloadedData |> DataFile(path: path + filename)
                        self.progress.dismiss(animated: true, completion: {
                            self.preview(filename)
                        })
                    }
                    return task
                })
            }catch let error {
                print(error)
            }
        }
    }
    func preview(_ filename:String){
        previewController.file = (Path.userDocuments + Path(getCurrentPath()) + filename).url
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(self.previewController, animated: true)
        }
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "aa")// TODO: Reuse
        var row = indexPath.row
        if(path.count > 0){
            if(row == 0){
                cell.textLabel?.text = "返回上级"
                return cell
            }
            row -= 1
        }
        cell.textLabel!.text = currentData[row].filename
        var text = ""
        if let size = currentData[row].size {
            if size != 0{
                if(isExist(currentData[row].filename)){
                    text += "已缓存 - "
                }else{
                    //rtext += calculateSize(bytes: size) + " - "
                }
            }
        }
        if let time = currentData[row].time {
            text += stringFormater.string(from: time)
        }
        cell.detailTextLabel!.text = text
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(path.count > 0){
            return currentData.count + 1
        } else {
            return currentData.count
        }
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var row = indexPath.row
        var cell = tableView.cellForRow(at: indexPath)!
        if(path.count > 0){
            if(row == 0){
                if(!self.multiMode){
                    self.goBack()
                }
                return
            }
            row -= 1
        }
        if(self.multiMode){
            if (cell.accessoryType == .checkmark) {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .checkmark
            }
        }else{
            if(currentData[indexPath.row].size == 0){
                goToFolder(file: currentData[indexPath.row].filename)
            }else{
                download(currentData[indexPath.row].filename)
            }
        }
        
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
