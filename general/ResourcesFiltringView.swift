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


class ResourcesFiltringViewController:UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet weak var confuguireButton: UIButton!
    
    @IBOutlet weak var barItem: UIBarButtonItem!
    @IBOutlet weak var searchField: UITextField!
    let ID = "Cell"
    var filenames = [String]()
    var times = [Int]()
    var sizes = [Int]()
    var isFolder = [Bool]()
    var isDownloaded = [Bool]()
    var currentFolder = ""
    var loadingController = UIAlertController()
    var operatingController = UIAlertController()
    var errorController = UIAlertController()
    var reactWithClick = true
    var onlineMode = true
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingController = UIAlertController(title: "加载中", message: "数据加载中，请稍后", preferredStyle: .alert)
        operatingController = UIAlertController(title: "请稍后", message: "操作进行中", preferredStyle: .alert)
        errorController = UIAlertController(title: "加载错误", message: "网络或服务器故障，请稍后再试！", preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "重试", style: .cancel, handler: {
            action in
            self.listRequest()
        })
        let listAction = UIAlertAction(title: "查看离线列表", style: .default, handler: {
            action in
            self.onlineMode = false
            self.listRequest()
        })
        tableview.allowsMultipleSelection = true
        errorController.addAction(retryAction)
        errorController.addAction(listAction)
        tableview.register(DownloadCell.self, forCellReuseIdentifier: ID)
    }
    
    func handleSwipeLeft(gesture:UIGestureRecognizer){
        let location = gesture.location(in: tableview)
        let indexPath = tableview.indexPathForRow(at: location)
        if((indexPath) != nil){
            let cell = tableview.cellForRow(at: indexPath!)!
            cell.accessoryType = .checkmark
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showPDF") {
            let secondViewController = segue.destination as! PDFViewController
            let path = sender as! String
            secondViewController.path = path
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        listRequest()
    }
    override func viewWillDisappear(_ animated: Bool) {
        removeFile(filename: "", path: "temp")
    }
    @IBAction func actionButtonPressed(_ sender: Any) {
        var mutipleSelectAction = UIAlertAction()
        let alertController = UIAlertController(title: "选项", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
        if(reactWithClick){
            let showTipsAction = UIAlertAction(title: "Tips", style: UIAlertActionStyle.default, handler: {
                (alert: UIAlertAction!) in
                self.showTips()
            })
            alertController.addAction(showTipsAction)
            if(onlineMode){
                mutipleSelectAction = UIAlertAction(title: "多选模式", style: UIAlertActionStyle.default, handler: {
                    (alert: UIAlertAction!) in
                    self.reactWithClick = !self.reactWithClick
                    self.tableview.reloadData()
                })
                alertController.addAction(mutipleSelectAction)
                let showHeadersFootersAction = UIAlertAction(title: "显示页眉页脚", style: UIAlertActionStyle.default, handler: {
                    (alert: UIAlertAction) in
                    self.showHeaderFooter(force: true)
                })
                alertController.addAction(showHeadersFootersAction)
                /*
                let catogorySearchAction = UIAlertAction(title: "往卷分类搜索", style: UIAlertActionStyle.default, handler: nil)
                alertController.addAction(catogorySearchAction)
                 */
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
        alertController.popoverPresentationController?.barButtonItem = barItem
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)

    }
    
    
    func listRequest(){
        filenames = [String]()
        times = [Int]()
        sizes = [Int]()
        isFolder = [Bool]()
        isDownloaded = [Bool]()
        if(self.currentFolder.isEmpty){
            filenames.append(" ")
        } else {
            filenames.append("返回")
        }
        
        times.append(0)
        sizes.append(0)
        isFolder.append(true)
        isDownloaded.append(false)
        if(!onlineMode){
            localRequest()
            return
        }
        self.present(loadingController, animated: true)
        searchField.placeholder = "过滤 " + currentFolder.removingPercentEncoding! + "/"
        let requestDetail:Parameters = [
            "href":currentFolder + "/",
            "what":1
        ]
        
        let parameters:Parameters = [
            "action":"get",
            "items":requestDetail
        ]
        
        Alamofire.request("https://dl.nfls.io/?", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{
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
                            if((self.searchField.text?.isEmpty)! || name.range(of: self.searchField.text!) != nil)
                            {
                                self.filenames.append(name)
                                self.times.append((file as! [String:Any])["time"] as! Int)
                                self.sizes.append((file as! [String:Any])["size"] as! Int)
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
                            if((self.searchField.text?.isEmpty)! || name.range(of: self.searchField.text!) != nil)
                            {
                                self.filenames.append(name)
                                self.times.append((file as! [String:Any])["time"] as! Int)
                                self.sizes.append((file as! [String:Any])["size"] as! Int)
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
                self.tableview.delegate = self
                self.tableview.dataSource = self
                self.tableview.reloadData()
                self.navigationBar.title = "资源中心"
                self.loadingController.dismiss(animated: true, completion: nil)
                self.showHeaderFooter()
                break
            default:
                self.loadingController.dismiss(animated: false, completion: {self.present(self.errorController, animated: true)})
                break
            }
        }
    }
    
    func localRequest(){
        searchField.isEnabled = false
        searchField.placeholder = ""
        navigationBar.title = "资源中心（离线）"
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
                    //print("target:"+documentsUrl.path + currentFolder.removingPercentEncoding! + "/")
                    let range = file.path.range(of: (documentsUrl.path + currentFolder.removingPercentEncoding! + "/"))
                    //print("haha:"+currentFolder)
                    let endIndex = file.path.distance(from: file.path.startIndex, to: range!.upperBound)
                    let name = (file.path as NSString).substring(from: endIndex)
                    filenames.append(name)
                    //dump(name.removingPercentEncoding)
                }
            }
        } catch let error as NSError {
            print(error)
        }
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
        self.present(operatingController, animated: true, completion: nil)
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("downloads").appendingPathComponent(path.removingPercentEncoding!).appendingPathComponent(filename)
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: fileURL.path)
        } catch {
            print("error")
        }
        operatingController.dismiss(animated: true, completion: {
            self.listRequest()
        })
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
            if(file.row != 0){
                parameters["hrefs[" + String(count) + "]"] = currentFolder + "/" + filenames[file.row].addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
                count += 1
            }
        }
        
        let downloading = UIAlertController(title: "文件下载",
                                            message: "您正在批量下载" + String(count) + "个文件，请不要退出APP！", preferredStyle: .alert)
        var request:Alamofire.Request?
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
            action in
            if(request != nil){
                request!.cancel()
            }
            self.listRequest()
        })
        downloading.addAction(cancelAction)
        if(count >= 1){
            self.present(downloading, animated: true, completion: nil)
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("temp/temp.zip")
            let unzipURL = documentsURL.appendingPathComponent("downloads").appendingPathComponent(self.currentFolder.removingPercentEncoding!)
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            request = Alamofire.download("https://dl.nfls.io/?", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil, to: destination).downloadProgress { progress in
                if(progress.fractionCompleted == 1.0){
                    SSZipArchive.unzipFile(atPath: fileURL.path, toDestination: unzipURL.path)
                }
                }.responseData(completionHandler: {
                    response in
                    SSZipArchive.unzipFile(atPath: fileURL.path, toDestination: unzipURL.path)
                    self.removeFile(filename: "temp.zip", path: documentsURL.appendingPathComponent("temp").path)
                    let finished = UIAlertController(title: "下载完成", message: String(count) + "个文件已下载完成", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "完成", style: .cancel, handler: {
                        action in
                            self.listRequest()
                    })
                    finished.addAction(okAction)
                    downloading.dismiss(animated: true, completion: {
                        self.present(finished, animated: true, completion: nil)
                        self.reactWithClick = true
                    })
            })
        } else {
            self.listRequest()
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
        debugPrint("The file will be downloaded to:" + fileURL.path)
        if (!isFileExists(filename: filename, path: path) || force || temp) {
            let downloading = UIAlertController(title: "文件下载",
                                                message: "您正在下载以下文件：" + filename, preferredStyle: .alert)
            var request:Alamofire.Request?
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
                action in
                if(request != nil){
                    request!.cancel()
                }
                self.listRequest()
            })
            downloading.addAction(cancelAction)
            
            self.present(downloading, animated: true, completion: nil)
            let utilityQueue = DispatchQueue.global(qos: .utility)
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            request = Alamofire.download(url,to: destination).downloadProgress(queue: utilityQueue) { progress in
                DispatchQueue.main.async {
                    if(progress.fractionCompleted != 1.0){
                        downloading.message = "您正在下载以下文件：" + filename + "，进度：" + String(format: "%.2f", progress.fractionCompleted * 100) + "%"
                    } else {
                        downloading.dismiss(animated: false, completion: {
                            let finished = UIAlertController(title: "下载完成", message: filename + "已下载完成", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "打开", style: .cancel, handler: {
                                action in
                                self.goToView(url: fileURL.path)
                            })
                            let doneAction = UIAlertAction(title: "完成", style: .default, handler: {
                                action in
                                self.listRequest()
                            })
                            finished.addAction(okAction)
                            finished.addAction(doneAction)
                            self.present(finished, animated: true, completion: nil)
                        })
                    }
                }
            }
        } else {
            self.goToView(url: fileURL.path)
            
        }
    }
    
    @IBAction func filtre(_ sender: Any) {
        listRequest()
    }
    
    func goToView(url:String){
        self.performSegue(withIdentifier: "showPDF", sender: url)
    }
    
    
    func changeCurrentDir(newDir:String,_ add:Bool = true){
        searchField.text = nil
        searchField.resignFirstResponder()
        if(add){
            let escapedString = newDir.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            currentFolder += "/" + escapedString!
        } else {
            var dir = String(currentFolder.characters.reversed())
            let range = dir.range(of: "/")
            let index = dir.distance(from: dir.startIndex, to: range!.upperBound)
            dir = (dir as NSString).substring(from: index)
            currentFolder = String(dir.characters.reversed())
        }
        print(currentFolder)
        
        listRequest()
    }
    
    func showTips(force: Bool = false){
        if(true){
        let tips = "1.向左滑动行可执行更多操作，具体可自行探索\n" +
                   "2.如想下载整个文件夹，请使用多选模式，然后选中单个或多个文件夹下载即可\n" +
                   "3.打开文件时默认会将文件缓存至本地，如果您的手机空间捉急，可选择“临时下载”\n" +
                   "4.当然，如果您觉得您的手机存储空间足够大，可以缓存所有文件\n" +
                   "5.其他功能就请自行探索吧（闷声大发财，那是最吼的）"
        let tipsController = UIAlertController(title: "Tips", message: tips, preferredStyle: .alert)
        (tipsController.view.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[1] as! UILabel).textAlignment = .left
        let doneAction = UIAlertAction(title: "我知道了", style: .default, handler: {
            (action: UIAlertAction) in
        })
        tipsController.addAction(doneAction)
        self.present(tipsController, animated: true, completion: nil)
        }
    }
    
    func showHeaderFooter(force: Bool = false){
        let parameters: Parameters = [
            "action": "get",
            "custom": "/" + currentFolder
        ]
        Alamofire.request("https://dl.nfls.io/?", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: {
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

                //print(headerPhrased.attributedString())
                //print(footerPhrased.attributedString())
            default:
                break

            }
            
        })
        //let md = SwiftyMarkdown
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filenames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: ID, for: indexPath as IndexPath)
        let name = filenames[indexPath.row]
        let size = sizes[indexPath.row] / 1000
        
        if(indexPath.row != 0){
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
            if(isFolder[indexPath.row]){
                cell.imageView!.image = UIImage(named: "icons8-Folder-50.png")
            } else {
                cell.imageView!.image = UIImage(named: "icons8-Documents-50.png")
            }
        }
        
        
        cell.textLabel!.text = name
        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        let rowIsSelected = selectedIndexPaths != nil && selectedIndexPaths!.contains(indexPath)
        cell.accessoryType = rowIsSelected ? .checkmark : .none
        cell.textLabel!.accessibilityElementsHidden = true;
        cell.detailTextLabel!.accessibilityElementsHidden = true;
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
        if(indexPath.row != 0){
            cell.accessoryType = .checkmark
        } else {
            cell.isSelected = false
        }
        
        tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.isSelected = false
        if(reactWithClick){
            if(isFolder[indexPath.row]){
                if(indexPath.row != 0){
                    changeCurrentDir(newDir : filenames[indexPath.row])
                } else {
                    if(!currentFolder.isEmpty){
                        changeCurrentDir(newDir: "", false)
                    }
                }
            } else {
                downloadFiles(url: "https://dl.nfls.io" + currentFolder + "/" + filenames[indexPath.row].addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!,filename:filenames[indexPath.row], path:currentFolder)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .none
        // cell.accessoryView.hidden = true  // if using a custom image
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if(indexPath.row == 0){
            return []
        }
        if(isFolder[indexPath.row]){
            let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "删除该文件夹下所有缓存", handler:{action, indexPath in
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
            //return []
        }
        
    }

    @IBAction func closePDF(segue: UIStoryboardSegue){
        
    }

    /*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        //let cell = tableView.dequeueReusableCell(withIdentifier: ID)
        //return cell!.textLabel!.frame.height + cell!.detailTextLabel!.frame.height
        return 100
    }
 */

}

class DownloadCell:UITableViewCell{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //self.accessibilityElementsHidden = true
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        //self.accessibilityElementsHidden = true
        //self.setUpUI()
    }
}

