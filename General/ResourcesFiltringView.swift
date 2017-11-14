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

class ResourcesFiltringViewController:UIViewController, UITableViewDataSource, UITableViewDelegate, QLPreviewControllerDelegate,QLPreviewControllerDataSource,UISearchBarDelegate{
    
    @IBOutlet weak var searchBar: UISearchBar!
    let ID = "Cell"
    var filenames = [String]()
    var times = [Int]()
    var sizes = [Int]()
    var isFolder = [Bool]()
    var isDownloaded = [Bool]()
    var images = [String?]()
    var appHref = [String]()
    var currentFolder = ""
    var reactWithClick = true
    var onlineMode = true
    
    var fileurls = [NSURL]()
    var useNew = true
    
    let operating = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
        showCloseButton: false
    ))
    
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
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
        MobClick.beginLogPageView("Resources")
    }
    override func viewWillDisappear(_ animated: Bool) {
        MobClick.endLogPageView("Resources")
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
                    self.bulkDownload(files: selectedRows!)
                }
            })
            alertController.addAction(mutipleSelectAction)
            alertController.addAction(downloadAction)
        }
        if(useNew){
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
        }
        alertController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    func listRequest(){
        filenames.removeAll()
        times.removeAll()
        sizes.removeAll()
        isFolder.removeAll()
        isDownloaded.removeAll()
        images.removeAll()
        if(!onlineMode){
            localRequest()
            return
        }
        let loading = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
            showCloseButton: false
        ))
        loading.addButton("离线模式") {
            self.onlineMode = false
            self.listRequest()
        }
        let responder = loading.showWait("请稍后", subTitle: "数据加载中")
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
                                self.filenames.append(name)
                                self.times.append(Int(truncating: (file as! [String:Any])["time"] as! NSNumber))
                                self.sizes.append(Int(truncating: (file as! [String:Any])["size"] as! NSNumber))
                                self.appHref.append((file as! [String:Any])["appHref"] as! String)
                                if((file as! [String:Any])["managed"] == nil){
                                    self.isFolder.append(false)
                                    self.isDownloaded.append(self.isFileExists(filename: name, path: self.currentFolder))
                                } else {
                                    self.isFolder.append(true)
                                    self.isDownloaded.append(false)
                                }
                            }
                            
                        }
                    }
                    if(self.currentFolder.isEmpty){
                        name = name.replacingOccurrences(of: "/", with: "")
                        name = name.removingPercentEncoding!
                        if(!name.isEmpty){
                            if((self.searchBar.text?.isEmpty)! || name.range(of: self.searchBar.text!) != nil)
                            {
                                self.filenames.append(name)
                                self.times.append(Int(truncating: (file as! [String:Any])["time"] as! NSNumber))
                                self.sizes.append(Int(truncating: (file as! [String:Any])["size"] as! NSNumber))
                                self.appHref.append((file as! [String:Any])["appHref"] as! String)
                                if((file as! [String:Any])["managed"] == nil){
                                    self.isFolder.append(false)
                                    self.isDownloaded.append(self.isFileExists(filename: name, path: self.currentFolder))
                                } else {
                                    self.isFolder.append(true)
                                    self.isDownloaded.append(false)
                                }
                            }
                        }
                    }
                }
                self.checkForYear()
                self.tableview.delegate = self
                self.tableview.dataSource = self
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
        if(!UserDefaults.standard.bool(forKey: "ettings.resources.rank")){
            for name in filenames{
                if(name.contains("2016")){
                    filenames.reverse()
                    times.reverse()
                    sizes.reverse()
                    isFolder.reverse()
                    isDownloaded.reverse()
                    images.reverse()
                    return
                }
            }
        }
        
    }
    func thumbRequest(){
        var requestImages = [Parameters]()
        for file in filenames{
            let parameters:Parameters = [
                "type":"doc",
                "href":currentFolder.removingPercentEncoding! + "/" + file,
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
                    if(isDir.boolValue){
                        dump(file)
                        isFolder.append(true)
                        var folderSize = 0
                        FileManager.default.enumerator(at: file, includingPropertiesForKeys: [.fileSizeKey], options: [])?.forEach {
                            folderSize += (try? ($0 as? URL)?.resourceValues(forKeys: [.fileSizeKey]))??.fileSize ?? 0
                        }
                        sizes.append(folderSize)
                    } else {
                        let attr = try FileManager.default.attributesOfItem(atPath: file.path)
                        let fileSize = attr[FileAttributeKey.size] as! Int
                        sizes.append(fileSize)
                        isFolder.append(false)
                    }
                    isDownloaded.append(true)
                    let range = file.path.range(of: (documentsUrl.path + currentFolder.removingPercentEncoding! + "/"))
                    let endIndex = file.path.distance(from: file.path.startIndex, to: range!.upperBound)
                    let name = (file.path as NSString).substring(from: endIndex)
                    filenames.append(name)
                }
            }
        } catch {
            //print(error)
        }
        self.checkForYear()

        self.tableview.delegate = self
        self.tableview.dataSource = self
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
    
    func bulkDownload(files:[IndexPath]!){
        var parameters:Parameters = [
            "action" : "download",
            "as" : "bulk.zip",
            "type" : "shell-zip",
            "baseHref" : currentFolder + "/",
            "hrefs" : ""
        ]
        var count = 0
        for file in files{
            parameters["hrefs[" + String(count) + "]"] = currentFolder + "/" + filenames[file.row].addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
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
            if(isFileExists(filename: filenames[path.row], path: currentFolder)){
                let fileURL = documentsURL.appendingPathComponent("downloads").appendingPathComponent(currentFolder.removingPercentEncoding!).appendingPathComponent(filenames[path.row])
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
                    self.navigationController!.pushViewController(qlpreview, animated: true)
                }
            }
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
            if(appHref[0].contains("https://nflsio.oss-cn-shanghai.aliyuncs.com")){
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
        return filenames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: ID, for: indexPath as IndexPath)
        cell.imageView!.kf.cancelDownloadTask()
        if(indexPath.row >= filenames.count){
            SCLAlertView().showError("错误", subTitle: "发生了内部错误，如果遇到奇怪问题请退出重试")
            return cell
        }
        let name = filenames[indexPath.row]
        let size = sizes[indexPath.row] / 1000
        if(onlineMode){
            let time = Date(timeIntervalSince1970: TimeInterval(times[indexPath.row]/1000))
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" //Specify your format that you want
            let strDate = dateFormatter.string(from: time)
            cell.detailTextLabel!.text = strDate + " - " + calculateSize(bytes: size)
            if(isDownloaded[indexPath.row]){
                cell.detailTextLabel!.text! += " - 已缓存"
            }
        } else {
            cell.detailTextLabel!.text = calculateSize(bytes: size)
        }
        var placeHolder = UIImage()
        if(isFolder[indexPath.row]){
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
        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        let rowIsSelected = selectedIndexPaths != nil && selectedIndexPaths!.contains(indexPath)
        cell.accessoryType = rowIsSelected ? .checkmark : .none
        cell.textLabel!.font = UIFont(name: "HelveticaBold", size: 18)
        cell.detailTextLabel!.font = UIFont(name: "Helvetica", size: 14)

        return cell
    }
    
    func calculateSize(bytes:Int) -> String {
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
        return String(format: "%.1f", size) + " " + quantity
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .checkmark
        tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.isSelected = false
        if(reactWithClick){
            if(isFolder[indexPath.row]){
                changeCurrentDir(newDir : filenames[indexPath.row])
            } else {
                downloadFiles(url: "https://dl.nfls.io" + currentFolder + "/" + filenames[indexPath.row].addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!,filename:filenames[indexPath.row], path:currentFolder)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if(isFolder[indexPath.row]){
            let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "删空缓存", handler:{action, indexPath in
                self.removeFile(filename:self.filenames[indexPath.row], path:self.currentFolder)
            })
            return [deleteRowAction]
        }
        if(isDownloaded[indexPath.row]){
            let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "删除本地", handler:{action, indexPath in
                self.removeFile(filename:self.filenames[indexPath.row], path:self.currentFolder)
            })
            if(onlineMode){
                let moreRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "重新下载", handler:{action, indexpath in
                    self.downloadFiles(url: "https://dl.nfls.io" + self.currentFolder + "/" + self.filenames[indexPath.row].addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!,filename:self.filenames[indexPath.row], path:self.currentFolder, force: true)
                })
                moreRowAction.backgroundColor = UIColor.blue
                
                
                return [deleteRowAction, moreRowAction]
                
            } else {
                return [deleteRowAction]
            }
            
        } else {
            let moreRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "临时下载", handler:{action, indexpath in
                self.downloadFiles(url: "https://dl.nfls.io" + self.currentFolder + "/" + self.filenames[indexPath.row].addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!,filename:self.filenames[indexPath.row], path:self.currentFolder, force: false, temp: true)
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

