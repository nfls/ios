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

class ResourcesViewController:UITableViewController {
    let oauth2 = NFLSOauth2()
    var data = [File]()
    var currentData = [File]()
    var path = [String]()
    let dateFormatter = DateFormatter()
    let stringFormater = DateFormatter()
    var client = OSSClient()
    let previewController = PreviewController()
    let load = UIAlertController(title: "加载中", message: "请稍后", preferredStyle: .alert)
    struct File{
        var filename:String
        var time:Date?
        var size:Int?
    }
    override func viewDidLoad() {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        stringFormater.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        let req = oauth2.oauth2.request(forURL: URL(string: "https://api-v3.nfls.io/oauth/downloadSts")!)
        
        self.present(self.load, animated: true)
        oauth2.oauth2.perform(request: req) { (response) in
            DispatchQueue.main.async {
                self.load.message = "正在与阿里云进行通讯"
            }
            let data = try! JSON(data: response.data!)
            let provider = OSSStsTokenCredentialProvider(accessKeyId: data["data"]["AccessKeyId"].string!, secretKeyId: data["data"]["AccessKeySecret"].string!, securityToken: data["data"]["SecurityToken"].string!)
            self.client = OSSClient(endpoint: "https://oss-cn-shanghai.aliyuncs.com", credentialProvider: provider)
            self.loadData()
        }
        self.navigationItem.hidesBackButton = true
    }
    @objc func goBack(){
        if(path.count == 1){
            self.navigationItem.rightBarButtonItem = nil
        }
        refresh()
    }
    func loadData(next:String? = nil){
        let bucket = OSSGetBucketRequest()
        bucket.bucketName = "nflsio"
        bucket.maxKeys = 1000
        bucket.marker = next ?? ""
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
            }
            return task
        })
    }
    func goToFolder(file:String){
        path.append(file)
        let button = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(goBack))
        self.navigationItem.rightBarButtonItem = button
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
    func calculateSize(bytes:Int) -> String {
        var size = Double(bytes) / 1024
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
    func download(_ filename:String){
        let request = OSSGetObjectRequest()
        request.bucketName = "nflsio"
        request.objectKey = getCurrentPath() + filename
        let path = Path.userDocuments + Path(getCurrentPath())
        if(path + filename).exists{
            self.preview(filename)
        }else{
            do{
                try path.createDirectory(withIntermediateDirectories: true)
                //request.downloadToFileURL = path.url.isFileURL
                request.downloadProgress = { bytesWritten, totalBytesWritten, bytesExpectedToWritten in
                    print(totalBytesWritten)
                }
                //print(request.downloadToFileURL)
                let task = client.getObject(request)
                task.continue({ task -> Any? in
                    if let error = task.error {
                        print(error)
                    }else{
                        let result = task.result as! OSSGetObjectResult
                        try? result.downloadedData |> DataFile(path: path + filename)
                        self.preview(filename)
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
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "aa")
        cell.textLabel!.text = currentData[indexPath.row].filename
        var text = ""
        if let size = currentData[indexPath.row].size {
            if size != 0{
                text += calculateSize(bytes: size) + " - "
            }
        }
        if let time = currentData[indexPath.row].time {
            text += stringFormater.string(from: time)
        }
        cell.detailTextLabel!.text = text
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentData.count
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(currentData[indexPath.row].size == 0){
            goToFolder(file: currentData[indexPath.row].filename)
        }else{
            download(currentData[indexPath.row].filename)
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
