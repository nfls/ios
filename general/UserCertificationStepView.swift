//
//  UserCertificationStepView.swift
//  NFLSers-iOS
//
//  Created by 胡清阳 on 08/06/2017.
//  Copyright © 2017 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import Alamofire

class UserCertificationStepView:UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var container: UIStackView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var showIntro: UIButton!
    var pickerOption = 0
    var pickerData: [String] = [String]()
    var currentStep:Step = .basicInfo
    var setPicker:Bool = false
    var tagMap = [Int:String]()
    var lastTag = 0
    //var typeMap = [Int:FormType]()
    enum Step:Int{
        case basicInfo = 1
        case primaryInfo = 2
        case juniorInfo = 3
        case seniorInfo = 4
        case confirmInfo = 5
        case collegeInfo = 6
        case workInfo = 7
        case personalInfo = 8
        case end = 9
    }
    
    
    enum FormType{
        case textField
        case textView
        case picker
        case datePicker
        case switch_
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPicker = false
        nextButton.addTarget(self, action: #selector(buttonPressed(button:)), for: .touchUpInside)
        nextButton.tag = 1
        previousButton.addTarget(self, action: #selector(buttonPressed(button:)), for: .touchUpInside)
        previousButton.tag = -1
        saveButton.addTarget(self, action: #selector(buttonPressed(button:)), for: .touchUpInside)
        saveButton.tag = 0
        resetButton.addTarget(self, action: #selector(reset(button:)), for: .touchUpInside)
        showIntro.addTarget(self, action: #selector(showIntroductions(button:)), for: .touchUpInside)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        initialize(true)
    }
    func showBasicInstructions(_ continue_:Bool = true){
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/alumni/auth/instructions", headers: headers).responseJSON { response in
            switch(response.result){
            case .success(let json):
                let messages = (json as! [String:AnyObject])["message"] as! [String]
                let alert = UIAlertAction(title: "我知道了", style: .default, handler: {
                    (alert: UIAlertAction!) in self.getCurrentStep(continue_)
                })
                self.showMessage(messages: messages,title: "注意事项",alert)
            default:
                break
            }
        }
    }
    
    func initialize(_ showInfo:Bool = false){
        disableButtons()
        cleanStackview()
        if(showInfo){
            showBasicInstructions()
        } else {
            getCurrentStep()
        }
    }
    
    func getCurrentStep(_ continue_:Bool = true){
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/alumni/auth/step", headers: headers).responseJSON { response in
            switch(response.result){
            case .success(let json):
                let messages = (json as! [String:AnyObject])["instructions"] as! [String]
                self.showMessage(messages: messages,title: "当前步骤提示")
                if(continue_){
                    self.updateForm(Step(rawValue : (json as! [String:AnyObject])["step"] as! Int)!)
                    Alamofire.request("https://api.nfls.io/alumni/auth/" + String((json as! [String:AnyObject])["step"] as! Int) + "/query", headers: headers).responseJSON(completionHandler: { (resp0nse) in
                        //print(resp0nse.result)
                        switch(resp0nse.result){
                        case .success(let json):
                            let data = (json as! [String:AnyObject])["info"] as? [String:Any?]
                            if(data != nil){
                                self.loadData(data: data!)
                            } else {
                                let data = (json as! [String:AnyObject])["info"] as? [String]
                                if(data != nil){
                                    self.loadData(messages: data!)
                                }
                            }
                            break
                        default:
                            break
                        }
                    })
                    
                }
            default:
                break
            }
            self.enableButtons()
        }
    }
    
    func cleanStackview(){
        DispatchQueue.main.async{
            for view in self.container.subviews {
                view.removeFromSuperview()
            }
        }
    }
    
    func enableButtons(){
        DispatchQueue.main.async{
            self.activityIndicator.isHidden = true
            self.resetButton.isEnabled = true
            if(self.currentStep != .basicInfo){
                self.previousButton.isEnabled = true
            }
            self.showIntro.isEnabled = true
            self.backButton.isEnabled = true
            if(self.currentStep != .end){
                self.nextButton.isEnabled = true
                self.saveButton.isEnabled = true
            }
        }
    }
    
    func disableButtons(){
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = false
            self.resetButton.isEnabled = false
            self.nextButton.isEnabled = false
            self.previousButton.isEnabled = false
            self.saveButton.isEnabled = false
            self.showIntro.isEnabled = false
            self.backButton.isEnabled = false
        }
    }
    
    func updateForm(_ step:Step){
        tagMap.removeAll()
        lastTag = 0
        currentStep = step
       // let type　= TagInt()
        DispatchQueue.main.async {
            switch(step){
            case .basicInfo:
                self.addFormItem(rootStackView: self.container, type: .textField, name: "用户名", identifyName: "username")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "邮箱", identifyName: "email")
                 self.addFormItem(rootStackView: self.container, type: .picker, name: "性别", identifyName: "gender", ["其他/保密","男","女"])
                self.addFormItem(rootStackView: self.container, type: .textField, name: "真实姓名", identifyName: "realname")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "曾用名", identifyName: "usedname")
                self.addFormItem(rootStackView: self.container, type: .datePicker, name: "出生日期", identifyName: "birthday")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "英文名", identifyName: "english_name")
                break
            case .primaryInfo:
                self.addFormItem(rootStackView: self.container, type: .picker, name: "小学学校" ,identifyName:"primary_school_no", ["其他学校","基础教育课程"])
                self.addFormItem(rootStackView: self.container, type: .textField, name: "小学就读学校", identifyName:"primary_school_name")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "小学班级号", identifyName:"primary_class")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "小学毕业年份", identifyName:"primary_school_graduated_year")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "小学入学年份", identifyName:"primary_school_enter_year")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "备注", identifyName:"primary_remark")
                break
            case .juniorInfo:
                self.addFormItem(rootStackView: self.container, type: .picker, name: "初中学校",identifyName: "junior_school_no",["其他学校","普通初中课程","基础教育初中课程"])
                self.addFormItem(rootStackView: self.container, type: .textField, name: "初中就读学校", identifyName:"junior_school_name")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "初中毕业年份", identifyName:"junior_school_graduated_year")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "初中入学年份", identifyName:"junior_school_enter_year")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "初中班级号", identifyName:"junior_class")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "备注", identifyName:"junior_remark")
                break
            case .seniorInfo:
                self.addFormItem(rootStackView: self.container, type: .picker, name: "高中学校",identifyName: "senior_school_no", ["无高中学历","其他国内学校","其他国外学校（如美高）","普通高中课程","IB国际课程","A-Level国际课程","中加国际课程","新南威尔士大学预科课程","日语代培课程","中师课程","基础教育高中课程"])
                self.addFormItem(rootStackView: self.container, type: .textField, name: "高中就读学校",identifyName:"senior_school_name")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "高中毕业年份",identifyName:"senior_school_graduated_year")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "高中入学年份",identifyName:"senior_school_enter_year")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "高中班级号",identifyName:"senior_class")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "高一上班级号",identifyName:"senior_class_11")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "高一下班级号",identifyName:"senior_class_12")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "高二上班级号",identifyName:"senior_class_21")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "高二下班级号",identifyName:"senior_class_22")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "高三上班级号",identifyName:"senior_class_31")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "高三下班级号",identifyName:"senior_class_32")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "备注",identifyName:"senior_remark")
                break
            case .confirmInfo:
                self.addFormItem(rootStackView: self.container, type: .textView, name: "提示", identifyName: nil)
                break
            case .collegeInfo:
                self.addFormItem(rootStackView: self.container, type: .switch_, name: "夏校", identifyName: "summer")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "就读院校ID",identifyName:"summer_school")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "主要专业方向",identifyName:"summer_major")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "毕业年份",identifyName:"summer_end")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "入学年份",identifyName:"summer_start")
                self.addFormItem(rootStackView: self.container, type: .switch_, name: "专科", identifyName: "college")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "就读院校ID",identifyName:"college_school")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "主要专业方向",identifyName:"college_major")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "毕业年份",identifyName:"college_end")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "入学年份",identifyName:"college_start")
                self.addFormItem(rootStackView: self.container, type: .switch_, name: "本科", identifyName: "undergraduate")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "就读院校ID",identifyName:"undergraduate_school")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "主要专业方向",identifyName:"undergraduate_major")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "毕业年份",identifyName:"undergraduate_end")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "入学年份",identifyName:"undergraduate_start")
                self.addFormItem(rootStackView: self.container, type: .switch_, name: "硕士", identifyName: "master")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "就读院校ID",identifyName:"master_school")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "主要专业方向",identifyName:"master_major")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "毕业年份",identifyName:"master_end")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "入学年份",identifyName:"master_start")
                self.addFormItem(rootStackView: self.container, type: .switch_, name: "博士", identifyName: "doctor")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "就读院校ID",identifyName:"doctor_school")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "主要专业方向",identifyName:"doctor_major")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "毕业年份",identifyName:"doctor_end")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "入学年份",identifyName:"doctor_start")
                self.addFormItem(rootStackView: self.container, type: .switch_, name: "其他", identifyName: "other")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "就读类型",identifyName:"other_type")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "就读院校",identifyName:"other_school")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "主要专业方向",identifyName:"other_major")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "毕业年份",identifyName:"other_end")
                self.addFormItem(rootStackView: self.container, type: .textField, name: "入学年份",identifyName:"other_start")

                break
            case .workInfo:
                //self.addFormItem(rootStackView: self.container, type: .textView, name: "工作信息",identifyName:.workType)
                break
            case .personalInfo:
                /*
                self.addFormItem(rootStackView: self.container, type: .textView, name: "个 人 介 绍", identifyName:.personalInfo )
                self.addFormItem(rootStackView: self.container, type: .textField, name: "WeChat", identifyName: .personalInfo, PersonalInfoType.wechat.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "QQ", identifyName: .personalInfo, PersonalInfoType.qq.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "微博", identifyName: .personalInfo, PersonalInfoType.weibo.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "Telegram", identifyName: .personalInfo, PersonalInfoType.telegram.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "WhatsApp", identifyName: .personalInfo, PersonalInfoType.whatsapp.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "Skype", identifyName: .personalInfo, PersonalInfoType.skype.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "Google  Talk", identifyName: .personalInfo, PersonalInfoType.google_talk.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "Snapchat", identifyName: .personalInfo, PersonalInfoType.snapchat.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "Viber", identifyName: .personalInfo, PersonalInfoType.viber.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "GroupMe", identifyName: .personalInfo, PersonalInfoType.groupme.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "Twitter", identifyName: .personalInfo, PersonalInfoType.twitter.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "Youtube", identifyName: .personalInfo, PersonalInfoType.youtube.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "Facebook", identifyName: .personalInfo, PersonalInfoType.facebook.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "Vimeo", identifyName: .personalInfo, PersonalInfoType.vimeo.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "Instagram", identifyName: .personalInfo, PersonalInfoType.instagram.rawValue)
                */
                break
            case .end:
                print(1)
                break
            }
            //self.addContainerSpacing(rootStackView: self.container, itemNum: 4)
            self.container.frame.size.height = 100
            self.container.layer.borderColor = UIColor.gray.cgColor
            self.container.layer.borderWidth = 1.0
            self.container.layer.cornerRadius = 5.0
            self.addBlankArea(rootStackView: self.container)
            
        }
        
    }
    
    func updateTextfield(selected:Int){
        DispatchQueue.main.async {
            self.pickerOption = selected
            //self.fadeInOrOut(object: self.container, isIn: false)
            let nfls_primary_info = ["primary_school_graduated_year","primary_school_enter_year","primary_class"]
            let nfls_junior_info = ["junior_school_graduated_year","junior_school_enter_year","junior_class"]
            let junior_school_div = ["junior_school_name"]
            let senior_school_div = ["senior_school_name"]
            let nfls_senior_general = ["senior_school_graduated_year","senior_school_enter_year"]
            let nfls_international_info = ["senior_class"]
            let nfls_senior_info = ["senior_class_11","senior_class_12","senior_class_21","senior_class_22","senior_class_31","senior_class_32"]
            switch(self.currentStep){
            case .primaryInfo:
                switch(selected){
                case 0:
                    self.operateGroups(group: nfls_primary_info, operation: false)
                    break
                case 1:
                    self.operateGroups(group: nfls_primary_info, operation: true)
                    break
                default:
                    break
                }
                break
            case .juniorInfo:
                switch(selected){
                case 0:
                    self.operateGroups(group: nfls_junior_info, operation: false)
                    self.operateGroups(group: junior_school_div, operation: true)
                    break
                case 1,2:
                    self.operateGroups(group: nfls_junior_info, operation: true)
                    self.operateGroups(group: junior_school_div, operation: false)
                    break
                default:
                    break
                }
            case .seniorInfo:
                switch(selected){
                case 0:
                    self.operateGroups(group: senior_school_div, operation: false)
                    self.operateGroups(group: nfls_international_info, operation: false)
                    self.operateGroups(group: nfls_senior_info, operation: false)
                    self.operateGroups(group: nfls_senior_general, operation: false)
                    break
                case 1,2:
                    self.operateGroups(group: senior_school_div, operation: true)
                    self.operateGroups(group: nfls_international_info, operation: false)
                    self.operateGroups(group: nfls_senior_info, operation: false)
                    self.operateGroups(group: nfls_senior_general, operation: false)
                    break
                case 3:
                    self.operateGroups(group: senior_school_div, operation: true)
                    self.operateGroups(group: nfls_international_info, operation: false)
                    self.operateGroups(group: nfls_senior_info, operation: true)
                    self.operateGroups(group: nfls_senior_general, operation: true)
                    break
                case 4,5,6,7,10:
                    self.operateGroups(group: senior_school_div, operation: false)
                    self.operateGroups(group: nfls_international_info, operation: true)
                    self.operateGroups(group: nfls_senior_general, operation: true)
                    self.operateGroups(group: nfls_senior_info, operation: false)
                    break
                case 8,9:
                    self.operateGroups(group: senior_school_div, operation: false)
                    self.operateGroups(group: nfls_international_info, operation: false)
                    self.operateGroups(group: nfls_senior_general, operation: true)
                    self.operateGroups(group: nfls_senior_info, operation: false)
                    break
                default:
                    break
                }
            default:
                break
            }
            //self.fadeInOrOut(object: self.container, isIn: true)
        }
    }
    
    func operateGroups(group:[String],operation:Bool){
        //dump(tagMap)
        for field in group{
            //print(field)
            let tag = findTagForIdentification(field)
            //print(tag)
            self.container.viewWithTag(tag)?.isHidden = !operation
            self.container.viewWithTag(-tag)?.isHidden = !operation
        }
    }
    
    func loadData(data:[String:Any?]){
        for(name,value) in data{
            var str:String
            if(value is String){
                str = value as! String
            }else if(value is Int){
                str = String(value as! Int)
            }else if(value is [Any]){
                str = ""
                for id in (value as! [Any]){
                    if(id is Int){
                        str += String(describing: id) + ","
                    } else {
                         str += (id as! String) + ","
                    }
                }
            }else{
                str = " "
            }
            let tag = findTagForIdentification(name)
            let view = self.container.viewWithTag(tag)
            if(view is UITextField){
                let textfield = view as! UITextField
                textfield.text = str
            }else if (view is UIDatePicker){
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy/MM/dd"
                let date = dateFormatter.date(from: str)!
                (self.container.viewWithTag(tag) as! UIDatePicker).setDate(date, animated: true)
            }else if (view is UISwitch){
                
            }else if (view is UIPickerView){
                let picker = view as! UIPickerView
                picker.selectRow(value as! Int, inComponent: 0, animated: true)
                self.pickerOption = value as! Int
                self.updateTextfield(selected: self.pickerOption)
            }
        }
    }
    
    func loadData(messages:[String]){
        var str = ""
        for message in messages {
            str += message + "\n"
        }
        (self.container.viewWithTag(1) as! UITextView).text = str
        (self.container.viewWithTag(1) as! UITextView).isEditable = false
        (self.container.viewWithTag(1) as! UITextView).isHidden = false
    }
    
    func findTagForIdentification(_ id:String) -> Int{
        for(name,value) in tagMap {
            if (value == id){
                return name
            }
        }
        return 0
    }
    @objc func buttonPressed(button:UIButton){
        disableButtons()
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
        var jsonDictionary = Parameters()
        jsonDictionary["action"] = button.tag as AnyObject
        for(key,value)in tagMap{
            let view = self.container.viewWithTag(key)
            if(view?.isHidden == false){
                if(view is UITextField){
                    jsonDictionary[value] = (view as! UITextField).text
                }else if (view is UIDatePicker){
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy/MM/dd"
                    let date = (view as! UIDatePicker).date
                    jsonDictionary[value]=dateFormatter.string(from: date)
                }else if (view is UISwitch){
                    
                }else if (view is UIPickerView){
                    jsonDictionary[value] = pickerOption
                }
            }
        }
        //dump(jsonDictionary)
        do {
            let parameters: Parameters = jsonDictionary
            let headers: HTTPHeaders = [
                "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
            ]
            Alamofire.request("https://api.nfls.io/alumni/auth/"+String(describing: self.currentStep.rawValue)+"/update", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (response) in
                switch(response.result){
                case .success(let json):
                    dump(json)
                    let messages = (json as! [String:AnyObject])["message"] as! [String]
                    self.showMessage(messages: messages, title: "信息")
                    //dump(response)
                    if((json as! [String:AnyObject])["code"] as! Int == 200){
                        self.initialize()
                    }
                    else{
                        self.enableButtons()
                    }
                    break
                default:
                    break
                }
            })
        }
    }
    
    
    func checkSwitchItems(jsonDictionary:inout [String:AnyObject]){
        
        /*
        jsonDictionary[prefix] = (self.container.viewWithTag(tag.rawValue) as! UISwitch).isOn as AnyObject
        if((self.container.viewWithTag(tag.rawValue) as! UISwitch).isOn == true)
        {
            jsonDictionary[prefix + "_school"] = getTextfieldText(tag: tag, TagInt.schoolName.rawValue)
            jsonDictionary[prefix + "_major"] = getTextfieldText(tag: tag, TagInt.major.rawValue)
            jsonDictionary[prefix + "_start"] = getTextfieldText(tag: tag, TagInt.enterYear.rawValue)
            jsonDictionary[prefix + "_end"] = getTextfieldText(tag: tag, TagInt.graduatedYear.rawValue)
            if(other){
                jsonDictionary[prefix + "_type"] = getTextfieldText(tag: tag, TagInt.schoolType.rawValue)
            }
        }
         */
        
    }
    func addFormItem(rootStackView:UIStackView,type:FormType,name:String,identifyName:String?,_ data:[String] = []){
        let label = UILabel()
        rootStackView.addArrangedSubview(label)
        rootStackView.spacing = 2
        label.text = name
        label.textAlignment = .left
        lastTag += 1
        if(identifyName != nil){
            tagMap[lastTag] = identifyName!
        }
        label.tag = -lastTag
        label.font = label.font.withSize(12)
        switch(type){
        case .textView:
            let textfield = UITextView()
            let constraintForTextView = NSLayoutConstraint(item: textfield, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 200)
            textfield.addConstraint(constraintForTextView)
            rootStackView.addArrangedSubview(textfield)
            textfield.tag = lastTag
            textfield.frame.size.height = 100
            textfield.layer.borderColor = UIColor.lightGray.cgColor
            textfield.layer.borderWidth = 1.0
            textfield.layer.cornerRadius = 5.0
            break
        case .textField:
            let textfield = UITextField()
            if((identifyName == "email") || (identifyName == "username")){
                textfield.isEnabled = false
                textfield.textColor = UIColor.gray
            }
            textfield.placeholder = name
            textfield.tag = lastTag
            textfield.borderStyle = .roundedRect
            rootStackView.addArrangedSubview(textfield)
            break
        case .picker:
            let picker = UIPickerView()
            let constraintForPicker = NSLayoutConstraint(item: picker, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 100)
            rootStackView.addArrangedSubview(picker)
            picker.addConstraint(constraintForPicker)
            picker.layer.borderColor = UIColor.lightGray.cgColor
            picker.layer.borderWidth = 1.0
            picker.layer.cornerRadius = 5.0
            picker.tag = lastTag
            picker.delegate = self
            picker.dataSource = self
            updateTextfield(selected: 0)
            self.pickerData = data
            break
        case .datePicker:
            let picker = UIDatePicker()
            rootStackView.addArrangedSubview(picker)
            picker.locale = Locale(identifier: "zh_CN")
            picker.datePickerMode = .date
            picker.layer.borderColor = UIColor.lightGray.cgColor
            picker.layer.borderWidth = 1.0
            picker.layer.cornerRadius = 5.0
            picker.tag = lastTag
            var components = DateComponents()
            components.year = -15
            let maxDate = Calendar.current.date(byAdding: components, to: Date())
            picker.maximumDate = maxDate
            break
        case .switch_:
            let switch_ = UISwitch()
            rootStackView.addArrangedSubview(switch_)
            switch_.addTarget(self, action: #selector(switchChanged(switch_:)), for: .valueChanged)
            switch_.tag = lastTag
            switch_.isOn = true
            break
        }
    }
    
    func showMessage(messages:[String] , title:String , _ action:UIAlertAction = UIAlertAction(title: "我知道了", style: .default, handler: nil)){
        var showMessage:String = ""
        
        var alert:UIAlertController
        if(messages.count != 1){
            var count = 0
            for message in messages {
                if(message != "非常抱歉，您提交的数据在以下部分存在问题："){
                    count = count + 1
                    showMessage = showMessage + String(count) + ". " + message + "\n"
                } else {
                    showMessage = showMessage + message + "\n"
                }
            }
            alert = UIAlertController(title: title, message: showMessage, preferredStyle: .alert)
            (alert.view.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[1] as! UILabel).textAlignment = .left
        } else {
            showMessage = messages[0]
            alert = UIAlertController(title: title, message: showMessage, preferredStyle: .alert)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func addBlankArea(rootStackView:UIStackView){
        let stackview = UIStackView()
        rootStackView.addArrangedSubview(stackview)
    }
    
    func pickerCheck(){
        if(!self.setPicker){
            self.updateTextfield(selected: 0)
        }
    }
    
    @objc func reset(button:UIButton){
        self.initialize()
    }
    
    @objc func switchChanged(switch_:UISwitch){
        let status = switch_.isOn
        let prefix = tagMap[switch_.tag]!
        let textfields = [prefix+"_name",prefix+"_major",prefix+"_start",prefix+"_end"]
        self.operateGroups(group: textfields, operation: status)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func showIntroductions(button:UIButton){
        disableButtons()
        showBasicInstructions(false)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateTextfield(selected: row)
    }
}
