//
//  ResourcesFiltringView.swift
//  Pods
//
//  Created by hqy on 2017/6/26.
//
//

import Foundation
import UIKit
import Alamofire
import SSZipArchive
import SwiftyMarkdown
import QuickLook
import SCLAlertView
import Kingfisher
import Cache

class ResourcesFiltringViewController:UIViewController, UITableViewDataSource, UITableViewDelegate, QLPreviewControllerDelegate,QLPreviewControllerDataSource,UISearchBarDelegate{
    
    @IBOutlet weak var searchBar: UISearchBar!
    let ID = "Cell"
    var currentFolder = ""
    var reactWithClick = true
    var onlineMode = true
    var fileurls = [NSURL]()
    let operating = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
        showCloseButton: false
    ))
    struct Detail{
        var filename:String
        var time:NSNumber
        var size:Int64
        var isFolder:Bool
        var appHref:String
        init(filename:String,time:NSNumber,size:Int64,isFolder:Bool,appHref:String){
            self.filename = filename
            self.time = time
            self.size = size
            self.isFolder = isFolder
            self.appHref = appHref
        }
    }
    var isFolder = [Bool]()
    var cached = [String]()
    var images = [String?]()
    var files = [Detail]()
    let storage = try? Storage(diskConfig: DiskConfig(name: "res"), memoryConfig: MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10))
    
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
       
        super.viewDidLoad()
        self.tableview.delegate = self
        self.tableview.dataSource = self
        let rightButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(setting))
        navigationItem.rightBarButtonItem = rightButton
        //navigationItem.leftItemsSupplementBackButton = true
        let leftButton = UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(back))
        //leftButton.icon(from: .FontAwesome, code: "reply", ofSize: 20)
        navigationItem.leftBarButtonItem = leftButton
        tableview.allowsMultipleSelection = true
        tableview.register(DownloadCell.self, forCellReuseIdentifier: ID)
        searchBar.delegate = self
        if #available(iOS 10.2, *){
            if #available(iOS 11.0, *){}else{
                SCLAlertView().showError("警告", subTitle: "您当前系统版本与部分电子书不兼容，请考虑升级")
            }
        }
    }
    
    @objc func back(){
        if(!currentFolder.isEmpty){
            changeCurrentDir(newDir: "", false)
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
    
    func handleSwipeLeft(gesture:UIGestureRecognizer){
        let location = gesture.location(in: tableview)
        let indexPath = tableview.indexPathForRow(at: location)
        if((indexPath) != nil){
            let cell = tableview.cellForRow(at: indexPath!)!
            cell.accessoryType = .checkmark
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        listRequest()
    }
    override func viewWillAppear(_ animated: Bool) {
        //MobClick.beginLogPageView("Resources")
        UIApplication.shared.isIdleTimerDisabled = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        //MobClick.endLogPageView("Resources")
    }
    @objc func setting() {
        var mutipleSelectAction = UIAlertAction()
        let alertController = UIAlertController(title: "选项", message: "您也可在电脑上访问https://dl.nfls.io", preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
        if(reactWithClick){
            mutipleSelectAction = UIAlertAction(title: "多选模式", style: UIAlertActionStyle.default, handler: {
                (alert: UIAlertAction!) in
                self.reactWithClick = !self.reactWithClick
                self.tableview.reloadData()
            })
            alertController.addAction(mutipleSelectAction)
            if(onlineMode){
                let showHeadersFootersAction = UIAlertAction(title: "显示页眉页脚", style: UIAlertActionStyle.default, handler: {
                    (alert: UIAlertAction) in
                    self.showHeaderFooter(force: true)
                })
                alertController.addAction(showHeadersFootersAction)
            }
            var offlineAction = UIAlertAction()
            if(self.onlineMode){
                offlineAction = UIAlertAction(title: "查看离线缓存", style: UIAlertActionStyle.default, handler: {
                    (alert: UIAlertAction!) in
                    self.onlineMode = false
                    self.title = "资源中心（离线）"
                    self.listRequest()
                })
            } else {
                offlineAction = UIAlertAction(title: "查看在线列表", style: UIAlertActionStyle.default, handler: {
                    (alert: UIAlertAction!) in
                    self.onlineMode = true
                    self.title = "资源中心"
                    self.listRequest()
                })
            }
            alertController.addAction(offlineAction)
            let deleteAction = UIAlertAction(title: "清空本地缓存", style: UIAlertActionStyle.destructive, handler: {
                (alert: UIAlertAction!) in
                self.removeFile(filename: "", path: "")
                try? self.storage?.removeAll()
            })
            
            alertController.addAction(deleteAction)
        } else {
            mutipleSelectAction = UIAlertAction(title: "单选模式", style: UIAlertActionStyle.default, handler: {
                (alert: UIAlertAction!) in
                self.reactWithClick = !self.reactWithClick
                self.tableview.reloadData()
            })
            let downloadAction = UIAlertAction(title: "下载所选文件", style: UIAlertActionStyle.destructive, handler: {
                (alert: UIAlertAction!) in
                let selectedRows = self.tableview.indexPathsForSelectedRows
                if(selectedRows != nil){
                    self.bulkDownload(files_: selectedRows!)
                }
            })
            alertController.addAction(mutipleSelectAction)
            alertController.addAction(downloadAction)
        }
        if(!self.reactWithClick){
            let previewAll = UIAlertAction(title:"预览所有选中文件", style: .default, handler: {
                alert in
                let selectedRows = self.tableview.indexPathsForSelectedRows
                if(selectedRows != nil){
                    self.bulkPreview(files: selectedRows!)
                }
                self.reactWithClick = !self.reactWithClick
                self.tableview.reloadData()
            })
            alertController.addAction(previewAll)
        }
        alertController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    func listRequest(){
        files.removeAll()
        
        if(!onlineMode){
            localRequest()
            return
        }
        let loading = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
            showCloseButton: false
        ))
        var responder = SCLAlertViewResponder(alertview: loading)
        if let cachedFilenames = try? storage?.entry(ofType: [String].self, forKey: "a" + currentFolder), let names = cachedFilenames?.object, let cachedStatus = try? storage?.entry(ofType: [Bool].self, forKey: "b" + currentFolder), let status = cachedStatus?.object  {
            cached = names
            isFolder = status
        }else{
            loading.addButton("离线模式") {
                self.onlineMode = false
                self.listRequest()
            }
            responder = loading.showWait("请稍后", subTitle: "数据加载中")
        }
        tableview.reloadData()
        
        searchBar.placeholder = "过滤 " + currentFolder.removingPercentEncoding! + "/"
        let requestDetail:Parameters = [
            "href":currentFolder + "/",
            "what":1
        ]
        let parameters:Parameters = [
            "action":"get",
            "items":requestDetail
        ]
        
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://dl.nfls.io/?", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result{
            case .success(let json):
                self.files.removeAll()
                let data = (json as! [String:AnyObject])["items"]! as! NSArray
                for file in data{
                    var name = (file as! [String:Any])["href"] as! String
                    if(name.range(of: self.currentFolder) != nil)
                    {
                        let range = name.range(of: self.currentFolder)
                        let endIndex = name.distance(from: name.startIndex, to: range!.upperBound)
                        
                        name = (name as NSString).substring(from: endIndex)
                        name = name.replacingOccurrences(of: "/", with: "")
                        name = name.removingPercentEncoding!
                        if(!name.isEmpty){
                            if((self.searchBar.text?.isEmpty)! || name.range(of: self.searchBar.text!) != nil)
                            {
                                if((file as! [String:Any])["managed"] == nil){
                                    self.files.append(Detail(filename: name, time: (file as! [String:Any])["time"] as! NSNumber, size: ((file as! [String:Any])["size"] as! NSNumber).int64Value, isFolder: false, appHref: (file as! [String:Any])["appHref"] as! String))
                                } else {
                                    self.files.append(Detail(filename: name, time: (file as! [String:Any])["time"] as! NSNumber, size: ((file as! [String:Any])["size"] as! NSNumber).int64Value, isFolder: true, appHref: (file as! [String:Any])["appHref"] as! String))
                                }
                                self.cached.removeAll()
                                self.isFolder.removeAll()
                            }
                            
                        }
                    }
                    if(self.currentFolder.isEmpty){
                        name = name.replacingOccurrences(of: "/", with: "")
                        name = name.removingPercentEncoding!
                        if(!name.isEmpty){
                            if((self.searchBar.text?.isEmpty)! || name.range(of: self.searchBar.text!) != nil)
                            {
                                if((file as! [String:Any])["managed"] == nil){
                                    self.files.append(Detail(filename: name, time: (file as! [String:Any])["time"] as! NSNumber, size: ((file as! [String:Any])["size"] as! NSNumber).int64Value, isFolder: false, appHref: (file as! [String:Any])["appHref"] as! String))
                                } else {
                                    self.files.append(Detail(filename: name, time: (file as! [String:Any])["time"] as! NSNumber, size: ((file as! [String:Any])["size"] as! NSNumber).int64Value, isFolder: true, appHref: (file as! [String:Any])["appHref"] as! String))
                                }
                            }
                        }
                    }
                }
                self.checkForYear()
                try? self.storage?.setObject(self.files.map { $0.filename }, forKey: "a" + self.currentFolder)
                try? self.storage?.setObject(self.files.map { $0.isFolder }, forKey: "b" + self.currentFolder)
                self.tableview.reloadData()
                responder.close()
                self.thumbRequest()
                self.showHeaderFooter()
                break
            default:
                responder.close()
                let error = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
                    showCloseButton: false
                ))
                error.addButton("重试") {
                    self.listRequest()
                }
                error.addButton("离线模式") {
                    self.onlineMode = false
                    self.listRequest()
                }
                error.showError("错误", subTitle: "列表加载失败")
                break
            }
        }
    }
    func checkForYear(){
        if(!UserDefaults.standard.bool(forKey: "settings.resources.rank")){
            for file in files{
                if(file.filename.contains("2016")){
                    files.reverse()
                    return
                }
            }
        }
        
    }
    func thumbRequest(){
        var requestImages = [Parameters]()
        for file in files{
            let parameters:Parameters = [
                "type":"doc",
                "href":currentFolder.removingPercentEncoding! + "/" + file.filename,
                "width":400,
                "height":400
            ]
            requestImages.append(parameters)
        }
        let parameters:Parameters = [
            "action":"get",
            "thumbs":requestImages
        ]
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://dl.nfls.io/?", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch(response.result){
            case .success(let json):
                if let images = json as? [String:AnyObject]{
                    let thumbs = images["thumbs"] as! [String?]
                    self.images = thumbs
                } else {
                    self.images.removeAll()
                }
            
                self.tableview.reloadData()
                break
            case .failure(_):
                break
            }
        }
        
        
    }
    func localRequest(){
        //searchBar.isHidden = true
        searchBar.placeholder = "离线模式下搜索不可用"
        navigationController!.title = "资源中心（离线）"
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("downloads")
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl.appendingPathComponent(currentFolder.removingPercentEncoding!), includingPropertiesForKeys: nil, options: [])
            for file in directoryContents{
                var isDir : ObjCBool = false
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: file.path, isDirectory:&isDir) {
                    let range = file.path.range(of: (documentsUrl.path + currentFolder.removingPercentEncoding! + "/"))
                    let endIndex = file.path.distance(from: file.path.startIndex, to: range!.upperBound)
                    let name = (file.path as NSString).substring(from: endIndex)
                    if(isDir.boolValue){
                        var folderSize:Int64 = 0
                        FileManager.default.enumerator(at: file, includingPropertiesForKeys: [.fileSizeKey], options: [])?.forEach {
                            folderSize = folderSize + Int64((try? ($0 as? URL)?.resourceValues(forKeys: [.fileSizeKey]))??.fileSize ?? 0)
                        }
                        self.files.append(Detail(filename: name, time: 0, size: folderSize, isFolder: true, appHref: ""))
                    } else {
                        let attr = try FileManager.default.attributesOfItem(atPath: file.path)
                        let fileSize = attr[FileAttributeKey.size] as! Int64
                        self.files.append(Detail(filename: name, time: 0, size: fileSize, isFolder: false, appHref: ""))
                    }
                    
                }
            }
        } catch {
            //print(error)
        }
        self.checkForYear()
        self.tableview.reloadData()
    }
    
    func isFileExists(filename:String,path:String) -> Bool{
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("downloads").appendingPathComponent(path.removingPercentEncoding!).appendingPathComponent(filename)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileURL.path) {
            return true
        } else {
            return false
        }
    }
    
    func removeFile(filename:String,path:String){
        
        let responder = operating.showWait("请稍后", subTitle: "操作进行中")
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("downloads").appendingPathComponent(path.removingPercentEncoding!).appendingPathComponent(filename)
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: fileURL.path)
        } catch {
            //print("removeError")
        }
        responder.close()
        self.listRequest()
    }
    
    func bulkDownload(files_:[IndexPath]!){
        var parameters:Parameters = [
            "action" : "download",
            "as" : "bulk.zip",
            "type" : "shell-zip",
            "baseHref" : currentFolder + "/",
            "hrefs" : ""
        ]
        var count = 0
        for file in files_{
            parameters["hrefs[" + String(count) + "]"] = currentFolder + "/" + self.files[file.row].filename.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
                count += 1
        }
        if(count >= 1){
            var request:Alamofire.Request?
            let downloading = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
                showCloseButton: false
            ))
            downloading.addButton("取消", action: {
                if(request != nil){
                    request!.cancel()
                }
                self.listRequest()
            })
            let responder = downloading.showWait("下载中", subTitle: "您正在批量下载" + String(count) + "个文件，请不要关闭App！")
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("temp/temp.zip")
            let unzipURL = documentsURL.appendingPathComponent("downloads").appendingPathComponent(self.currentFolder.removingPercentEncoding!)
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            let headers: HTTPHeaders = [
                "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
            ]
            request = Alamofire.download("https://dl.nfls.io/?", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers, to: destination).downloadProgress { progress in
                if(progress.fractionCompleted == 1.0){
                    SSZipArchive.unzipFile(atPath: fileURL.path, toDestination: unzipURL.path)
                }
                }.responseData(completionHandler: {
                    response in
                    SSZipArchive.unzipFile(atPath: fileURL.path, toDestination: unzipURL.path)
                    self.removeFile(filename: "temp.zip", path: documentsURL.appendingPathComponent("temp").path)
                    responder.close()
                    let done = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
                        showCloseButton: false
                    ))
                    done.addButton("完成", action: {
                        self.reactWithClick = true
                        self.listRequest()
                    })
                    done.showInfo("下载完成", subTitle: String(count) + " 个文件已下载完成")
                })
        } else {
            self.listRequest()
        }
    }
    
    func bulkPreview(files:[IndexPath]!){
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileurls.removeAll()
        for path in files{
            if(isFileExists(filename: self.files[path.row].filename, path: currentFolder)){
                let fileURL = documentsURL.appendingPathComponent("downloads").appendingPathComponent(currentFolder.removingPercentEncoding!).appendingPathComponent(self.files[path.row].filename)
                fileurls.append(fileURL as NSURL)
                print(fileURL.path)
            }
        }
        if(fileurls.count != files.count || files.count == 0){
            SCLAlertView().showError("错误", subTitle: "仅能预览已缓存的文件！")
        } else {
            let qlpreview = QLPreviewController()
            qlpreview.dataSource = self
            qlpreview.delegate = self
            qlpreview.reloadData()
            DispatchQueue.main.async {
                if !(self.navigationController?.topViewController is QLPreviewController){
                    self.setScreen()
                    self.navigationController!.pushViewController(qlpreview, animated: true)
                }
            }
        }
        
    }
    
    func setScreen(){
        let option = UserDefaults.standard.bool(forKey: "settings.keep.enabled")
        if option {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    func downloadFiles(url:String,filename:String,path:String,force:Bool = false, temp:Bool = false){
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var fileURL: URL
        if(temp){
            fileURL = documentsURL.appendingPathComponent("temp").appendingPathComponent(path.removingPercentEncoding!).appendingPathComponent(filename)
        }else{
            fileURL = documentsURL.appendingPathComponent("downloads").appendingPathComponent(path.removingPercentEncoding!).appendingPathComponent(filename)
        }
        if (!isFileExists(filename: filename, path: path) || force || temp) {
            var request:Alamofire.Request?
            let downloading = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
                showCloseButton: false
            ))
            downloading.addButton("取消", action: {
                if(request != nil){
                    request!.cancel()
                }
                self.listRequest()
            })
            let responder = downloading.showWait("下载中", subTitle: "您正在下载以下文件：" + filename + "，进度：0.00%")
            let utilityQueue = DispatchQueue.global(qos: .utility)
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            var myUrl = url
            if(self.files[0].filename.contains("https://nflsio.oss-cn-shanghai.aliyuncs.com")){
                myUrl = url.replacingOccurrences(of: "https://dl.nfls.io", with: "https://nflsio.oss-cn-shanghai.aliyuncs.com")
            }
            //print(myUrl)
            request = Alamofire.download(myUrl,to: destination).downloadProgress(queue: utilityQueue) { progress in
                DispatchQueue.main.async {
                    if(progress.fractionCompleted != 1.0){
                        responder.setSubTitle("您正在下载以下文件：" + filename + "，进度：" + String(format: "%.2f", progress.fractionCompleted * 100) + "%")
                    } else {
                        responder.close()
                        self.goToView(url: fileURL, filename: filename)
                    }
                }
            }
        } else {
            self.goToView(url: fileURL, filename: filename)
        }
    }
    func findAnswer(filename:String) -> Bool{
        if(fileurls.count == 2){
            return false
        }
        let filenames = files.map { $0.filename }
        if(filename.contains("qp")){
            let answer = filename.replacingOccurrences(of: "qp", with: "ms")
            if(filenames.contains(answer)){
                downloadFiles(url: "https://dl.nfls.io" + currentFolder + "/" + answer.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!,filename:answer, path:currentFolder)
                return true
            }else{
                return false
            }
        }else if(filename.contains("ms")){
            let answer = filename.replacingOccurrences(of: "ms", with: "qp")
            if(filenames.contains(answer)){
                downloadFiles(url: "https://dl.nfls.io" + currentFolder + "/" + answer.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!,filename:answer, path:currentFolder)
                return true
            }else{
                return false
            }
        }else if(filename.contains("._markscheme.pdf")){
            let answer = filename.replacingOccurrences(of: "._markscheme.pdf", with: ".pdf")
            if(filenames.contains(answer)){
                downloadFiles(url: "https://dl.nfls.io" + currentFolder + "/" + answer.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!,filename:answer, path:currentFolder)
                return true
            }else{
                return false
            }
        }else if(filename.contains(".pdf")){
            let answer = filename.replacingOccurrences(of: ".pdf", with: "_markscheme.pdf")
            if(filenames.contains(answer)){
                downloadFiles(url: "https://dl.nfls.io" + currentFolder + "/" + answer.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!,filename:answer, path:currentFolder)
                return true
            }else{
                return false
            }
        }else{
            return false
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        listRequest()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        listRequest()
    }
    func goToView(url:URL,filename:String){
        fileurls.append(url as NSURL)
        if(!self.findAnswer(filename: filename)){
            let qlpreview = QLPreviewController()
            qlpreview.dataSource = self
            qlpreview.delegate = self
            qlpreview.reloadData()
            qlpreview.currentPreviewItemIndex = 0
            DispatchQueue.main.async {
                if !(self.navigationController?.topViewController is QLPreviewController){
                    self.setScreen()
                    self.navigationController!.pushViewController(qlpreview, animated: true)
                }
            }
        }
    }
    
    func changeCurrentDir(newDir:String,_ add:Bool = true){
        searchBar.text = nil
        searchBar.resignFirstResponder()
        if(add){
            let escapedString = newDir.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            currentFolder += "/" + escapedString!
        } else {
            var dir = String(currentFolder.reversed())
            let range = dir.range(of: "/")
            let index = dir.distance(from: dir.startIndex, to: range!.upperBound)
            dir = (dir as NSString).substring(from: index)
            currentFolder = String(dir.reversed())
        }
        listRequest()
    }
    
    func showHeaderFooter(force: Bool = false){
        let parameters: Parameters = [
            "action": "get",
            "custom": "/" + currentFolder
        ]
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://dl.nfls.io/?", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: {
            response in
            switch(response.result){
            case .success(let json):
                let custom = (json as! [String:AnyObject])["custom"] as! [String:AnyObject]
                var header = ((custom["header"] as! [String:AnyObject]) as! [String:String])["content"]
                let footer = ((custom["footer"] as! [String:AnyObject]) as! [String:String])["content"]
                if(UserDefaults.standard.value(forKey: "dlHeader") as? String == nil || UserDefaults.standard.value(forKey: "dlHeader") as? String != header || force){
                    if(self.currentFolder.isEmpty){UserDefaults.standard.set(header, forKey: "dlHeader")}
                    header = header!.replacingOccurrences(of: "\r\n", with: "\n") + "\n" + footer!.replacingOccurrences(of: "\r\n", with: "\n")
                    let headerPhrased = SwiftyMarkdown(string: header!)
                    let alertController = UIAlertController(title: nil , message: nil , preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "我知道了", style: .default, handler: nil)
                    alertController.setValue(headerPhrased.attributedString(), forKey: "attributedMessage")
                    (alertController.view.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[0] as! UILabel).textAlignment = .left
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true)
                }
            default:
                break
                
            }
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(files.isEmpty){
            return cached.count
        }else{
            return files.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: ID, for: indexPath as IndexPath)
        cell.imageView!.kf.cancelDownloadTask()
        if(files.isEmpty){
            let name = cached[indexPath.row]
            let status = isFolder[indexPath.row]
            cell.textLabel?.text = name
            var placeHolder = UIImage()
            if(status){
                placeHolder = UIImage(named: "icons8-Folder-50.png")!
            } else {
                placeHolder = UIImage(named: "icons8-Documents-50.png")!
            }
            cell.detailTextLabel?.text = "Loading"
            if(isFileExists(filename: name, path: currentFolder)){
                cell.detailTextLabel?.text! += " - 已缓存"
            }
            cell.imageView!.image = placeHolder
        }else{
            if(indexPath.row >= files.count){
                SCLAlertView().showError("错误", subTitle: "发生了内部错误，如果遇到奇怪问题请退出重试")
                return cell
            }
            let name = files[indexPath.row].filename
            let size = files[indexPath.row].size / 1024
            if(onlineMode){
                let time = Date(timeIntervalSince1970: TimeInterval(truncating: files[indexPath.row].time)/1000)
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
                dateFormatter.locale = NSLocale.current
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" //Specify your format that you want
                let strDate = dateFormatter.string(from: time)
                cell.detailTextLabel!.text = strDate + " - " + calculateSize(bytes: size)
                if(isFileExists(filename: files[indexPath.row].filename, path: currentFolder)){
                    cell.detailTextLabel!.text! += " - 已缓存"
                }
            } else {
                cell.detailTextLabel!.text = calculateSize(bytes: size)
            }
            var placeHolder = UIImage()
            if(files[indexPath.row].isFolder){
                placeHolder = UIImage(named: "icons8-Folder-50.png")!
            } else {
                placeHolder = UIImage(named: "icons8-Documents-50.png")!
            }
            if(indexPath.row < images.count){
                if let url = images[indexPath.row] {
                    cell.imageView!.kf.setImage(with: URL(string:"https://dl.nfls.io" + url)!, placeholder: placeHolder, options: nil, progressBlock: nil)
                }else{
                    cell.imageView!.image = placeHolder
                }
            }else{
                cell.imageView!.image = placeHolder
            }
            cell.textLabel!.text = name
        }
        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        let rowIsSelected = selectedIndexPaths != nil && selectedIndexPaths!.contains(indexPath)
        cell.accessoryType = rowIsSelected ? .checkmark : .none
        cell.textLabel!.font = UIFont(name: "HelveticaBold", size: 18)
        cell.detailTextLabel!.font = UIFont(name: "Helvetica", size: 14)
        return cell
    }
    
    func calculateSize(bytes:Int64) -> String {
        var size = Double(bytes)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .checkmark
        if(reactWithClick){
            if(!files.isEmpty){
                if (files[indexPath.row].isFolder){
                    changeCurrentDir(newDir : files[indexPath.row].filename)
                } else {
                    downloadFiles(url: "https://dl.nfls.io" + currentFolder + "/" + files[indexPath.row].filename.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!,filename:files[indexPath.row].filename, path:currentFolder)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if(files[indexPath.row].isFolder){
            let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "删空缓存", handler:{action, indexPath in
                self.removeFile(filename:self.files[indexPath.row].filename, path:self.currentFolder)
            })
            return [deleteRowAction]
        }
        if(isFileExists(filename: self.files[indexPath.row].filename, path: currentFolder)){
            let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "删除本地", handler:{action, indexPath in
                self.removeFile(filename:self.files[indexPath.row].filename, path:self.currentFolder)
            })
            if(onlineMode){
                let moreRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "重新下载", handler:{action, indexpath in
                    self.downloadFiles(url: "https://dl.nfls.io" + self.currentFolder + "/" + self.files[indexPath.row].filename.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!,filename:self.files[indexPath.row].filename, path:self.currentFolder, force: true)
                })
                moreRowAction.backgroundColor = UIColor.blue
                
                
                return [deleteRowAction, moreRowAction]
                
            } else {
                return [deleteRowAction]
            }
            
        } else {
            let moreRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "临时下载", handler:{action, indexpath in
                self.downloadFiles(url: "https://dl.nfls.io" + self.currentFolder + "/" + self.files[indexPath.row].filename.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!,filename:self.files[indexPath.row].filename, path:self.currentFolder, force: false, temp: true)
            })
            moreRowAction.backgroundColor = UIColor.blue
            return [moreRowAction]
        }
        
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return fileurls.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileurls[index]
    }
    
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        fileurls.removeAll()
    }
    
}

class DownloadCell:UITableViewCell{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
}


