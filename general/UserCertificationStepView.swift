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
    
    var pickerData: [String] = [String]()
    var currentStep:Step = .basicInfo
    
    //let pickerTag:Int = -1
    let labelPrefix:Int = 10000
    let pickerTag:Int = -101
    var pickerOption:Int = -1
    var setPicker:Bool = false
    
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
    
    enum TagInt:Int{
        case graduatedYear = 1
        case enterYear = 2
        case classNo = 3
        case schoolType = 4
        case remark = 5
        case major = 6
        case schoolName = 7
        case workType = 8
        case nickName = 9
        case email = 10
        case userName = 11
        case usedName = 12
        case phoneIn = 13
        case phoneInter = 14
        case engName = 15
        case realName = 16
        case birthday = 17
        case gender = 18
        case confirmInfo = 19
        case picker = 1000
        case undergraduateSwitch = 2000
        case masterSwitch = 3000
        case doctorSwitch = 4000
        case collegeSwitch = 5000
        case otherSwitch = 6000
        case personalInfo = 7000
    }
    
    enum PrimarySchoolType:Int{
        case other = -1
        case nflsPrimary4 = 1
        case nflsPrimary2 = 2
    }
    
    enum JuniorSchoolType:Int{
        case other = -1
        case nflsJunior = 1
    }
    
    enum SeniorSchoolType:Int{
        case other = -1
        case nflsSeniorGeneral = 1
        case nflsSeniorIB = 2
        case nflsSeniorALevel = 3
        case nflsSeniorBCA = 4
    }
    
    enum PersonalInfoType:Int{
        case wechat = 1
        case qq = 2
        case weibo = 3
        case telegram = 4
        case whatsapp = 5
        case skype = 6
        case viber = 7
        case google_talk = 8
        case youtube = 9
        case twitter = 10
        case facebook = 11
        case vimeo = 12
        case instagram = 13
        case snapchat = 14
        case groupme = 15
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
                        switch(resp0nse.result){
                        case .success(let json):
                            let data = (json as! [String:AnyObject])["info"] as? [String:Any?]
                            if(data != nil){
                                self.loadData(data: data!)
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
        currentStep = step
       // let type　= TagInt()
        DispatchQueue.main.async {
            switch(step){
            case .basicInfo:
                self.addFormItem(rootStackView: self.container, type: .textField, name: "用户名", tag: .userName)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "邮箱", tag: .email)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "真实姓名", tag: .realName)
                self.addFormItem(rootStackView: self.container, type: .datePicker, name: "生日", tag: .birthday)
                self.addFormItem(rootStackView: self.container, type: .picker, name: "性别", tag: .gender, 0, ["其他/保密","男","女"])
                self.addFormItem(rootStackView: self.container, type: .textField, name: "曾用名", tag: .usedName)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "国内手机号码", tag: .phoneIn)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "国外手机号码", tag: .phoneInter)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "昵称", tag: .nickName)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "英文名", tag: .engName)
                break
            case .primaryInfo:
                self.addFormItem(rootStackView: self.container, type: .picker, name: "小学学校" ,tag:.picker , 0, ["其他学校","南京外国语学校小学部（四年制）","南京外国语学校小学部（两年制）"])
                self.addFormItem(rootStackView: self.container, type: .textField, name: "小学就读学校", tag:.schoolName)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "小学毕业年份", tag:.graduatedYear)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "小学入学年份", tag:.enterYear)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "备注", tag:.remark)
                break
            case .juniorInfo:
                self.addFormItem(rootStackView: self.container, type: .picker, name: "初中学校",tag: .picker, 0, ["其他学校","南京外国语学校初中部"])
                self.addFormItem(rootStackView: self.container, type: .textField, name: "初中就读学校", tag:.schoolName)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "初中毕业年份", tag:.graduatedYear)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "初中入学年份", tag:.enterYear)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "初中班级号", tag:.classNo)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "备注", tag:.remark)
                break
            case .seniorInfo:
                self.addFormItem(rootStackView: self.container, type: .picker, name: "高中学校",tag: .picker, 0, ["其他学校","南外普通高中","南外IB国际课程（国际文凭）班","南外剑桥国际课程（A-Level）班","南外中加（BCA）实验班"])
                self.addFormItem(rootStackView: self.container, type: .textField, name: "高中就读学校",tag:.schoolName)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "高中毕业年份",tag:.graduatedYear)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "高中入学年份",tag:.enterYear)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "高中班级号",tag:.classNo)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "高一上班级号",tag:.classNo,11)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "高一下班级号",tag:.classNo,12)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "高二上班级号",tag:.classNo,21)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "高二下班级号",tag:.classNo,22)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "高三上班级号",tag:.classNo,31)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "高三下班级号",tag:.classNo,32)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "备注",tag:.remark)
                
                break
            case .confirmInfo:
                self.addFormItem(rootStackView: self.container, type: .textView, name: "提示", tag: .confirmInfo)
                break
            case .collegeInfo:
                self.addFormItem(rootStackView: self.container, type: .switch_, name: "本科", tag: .undergraduateSwitch)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "本科就读学校",tag:.schoolName,TagInt.undergraduateSwitch.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "毕业年份",tag:.graduatedYear,TagInt.undergraduateSwitch.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "入学年份",tag:.enterYear,TagInt.undergraduateSwitch.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "主要专业方向",tag:.major,TagInt.undergraduateSwitch.rawValue)
                self.addFormItem(rootStackView: self.container, type: .switch_, name: "硕士", tag: .masterSwitch)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "硕士就读学校",tag:.schoolName,TagInt.masterSwitch.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "毕业年份",tag:.graduatedYear,TagInt.masterSwitch.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "入学年份",tag:.enterYear,TagInt.masterSwitch.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "主要专业方向",tag:.major,TagInt.masterSwitch.rawValue)
                self.addFormItem(rootStackView: self.container, type: .switch_, name: "博士", tag:.doctorSwitch)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "博士就读学校",tag:.schoolName,TagInt.doctorSwitch.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "毕业年份",tag:.graduatedYear,TagInt.doctorSwitch.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "入学年份",tag:.enterYear,TagInt.doctorSwitch.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "主要专业方向",tag:.major,TagInt.doctorSwitch.rawValue)
                self.addFormItem(rootStackView: self.container, type: .switch_, name: "专科", tag: .collegeSwitch)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "就读学校",tag:.schoolName,TagInt.collegeSwitch.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "毕业年份",tag:.graduatedYear,TagInt.collegeSwitch.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "入学年份",tag:.enterYear,TagInt.collegeSwitch.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "主要专业方向",tag:.major,TagInt.collegeSwitch.rawValue)
                self.addFormItem(rootStackView: self.container, type: .switch_, name: "其他", tag: .otherSwitch)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "类型",tag:.schoolType,TagInt.otherSwitch.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "就读学校",tag:.schoolName,TagInt.otherSwitch.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "毕业年份",tag:.graduatedYear,TagInt.otherSwitch.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "入学年份",tag:.enterYear,TagInt.otherSwitch.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "主要专业方向",tag:.major,TagInt.otherSwitch.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "备注", tag:.remark)
                break
            case .workInfo:
                self.addFormItem(rootStackView: self.container, type: .textView, name: "工作信息",tag:.workType)
                break
            case .personalInfo:
                self.addFormItem(rootStackView: self.container, type: .textView, name: "个 人 介 绍", tag:.personalInfo )
                self.addFormItem(rootStackView: self.container, type: .textField, name: "WeChat", tag: .personalInfo, PersonalInfoType.wechat.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "QQ", tag: .personalInfo, PersonalInfoType.qq.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "微博", tag: .personalInfo, PersonalInfoType.weibo.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "Telegram", tag: .personalInfo, PersonalInfoType.telegram.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "WhatsApp", tag: .personalInfo, PersonalInfoType.whatsapp.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "Skype", tag: .personalInfo, PersonalInfoType.skype.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "Google  Talk", tag: .personalInfo, PersonalInfoType.google_talk.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "Snapchat", tag: .personalInfo, PersonalInfoType.snapchat.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "Viber", tag: .personalInfo, PersonalInfoType.viber.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "GroupMe", tag: .personalInfo, PersonalInfoType.groupme.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "Twitter", tag: .personalInfo, PersonalInfoType.twitter.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "Youtube", tag: .personalInfo, PersonalInfoType.youtube.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "Facebook", tag: .personalInfo, PersonalInfoType.facebook.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "Vimeo", tag: .personalInfo, PersonalInfoType.vimeo.rawValue)
                self.addFormItem(rootStackView: self.container, type: .textField, name: "Instagram", tag: .personalInfo, PersonalInfoType.instagram.rawValue)
                break
            case .end:
                print(1)
                break
            }
            self.addContainerSpacing(rootStackView: self.container, itemNum: 4)
            self.container.frame.size.height = 100
            self.container.layer.borderColor = UIColor.gray.cgColor
            self.container.layer.borderWidth = 1.0
            self.container.layer.cornerRadius = 5.0
            self.addBlankArea(rootStackView: self.container)
            
        }
        
    }
    
    func updateTextfield(step:Step,selected:Int){
        DispatchQueue.main.async {
            //self.fadeInOrOut(object: self.container, isIn: false)
            self.pickerOption = selected
            if((selected==0) && (self.currentStep != .basicInfo)){
                print("yes")
                self.pickerOption = -1
            }
            switch(step){
            case .primaryInfo:
                let enumOption = PrimarySchoolType(rawValue: self.pickerOption)
                switch(enumOption!){
                case .other:
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.enterYear.rawValue) as! UITextField))
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.graduatedYear.rawValue) as! UITextField))
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.remark.rawValue) as! UITextField))
                    break
                case .nflsPrimary2,
                     .nflsPrimary4:
                    self.enableTextfield(textfield:(self.container.viewWithTag(TagInt.enterYear.rawValue) as! UITextField))
                    self.enableTextfield(textfield:(self.container.viewWithTag(TagInt.graduatedYear.rawValue) as! UITextField))
                    self.enableTextfield(textfield:(self.container.viewWithTag(TagInt.remark.rawValue) as! UITextField))
                    break
                }
                break
            case .juniorInfo:
                let enumOption = JuniorSchoolType(rawValue: self.pickerOption)
                switch(enumOption!){
                case .other:
                    self.enableTextfield(textfield:(self.container.viewWithTag(TagInt.schoolName.rawValue) as! UITextField))
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.enterYear.rawValue) as! UITextField))
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.graduatedYear.rawValue) as! UITextField))
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.classNo.rawValue) as! UITextField))
                    break
                case .nflsJunior:
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.schoolName.rawValue) as! UITextField))
                    self.enableTextfield(textfield:(self.container.viewWithTag(TagInt.enterYear.rawValue) as! UITextField))
                    self.enableTextfield(textfield:(self.container.viewWithTag(TagInt.graduatedYear.rawValue) as! UITextField))
                    self.enableTextfield(textfield:(self.container.viewWithTag(TagInt.classNo.rawValue) as! UITextField))
                    break
                }
                break
            case .seniorInfo:
                let enumOption = SeniorSchoolType(rawValue: self.pickerOption)
                switch(enumOption!){
                case .other:
                    self.enableTextfield(textfield:(self.container.viewWithTag(TagInt.schoolName.rawValue) as! UITextField))
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.enterYear.rawValue) as! UITextField))
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.graduatedYear.rawValue) as! UITextField))
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.classNo.rawValue) as! UITextField))
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.classNo.rawValue + 11) as! UITextField))
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.classNo.rawValue + 12) as! UITextField))
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.classNo.rawValue + 21) as! UITextField))
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.classNo.rawValue + 22) as! UITextField))
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.classNo.rawValue + 31) as! UITextField))
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.classNo.rawValue + 32) as! UITextField))
                    break
                case .nflsSeniorGeneral:
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.schoolName.rawValue) as! UITextField))
                    self.enableTextfield(textfield:(self.container.viewWithTag(TagInt.enterYear.rawValue) as! UITextField))
                    self.enableTextfield(textfield:(self.container.viewWithTag(TagInt.graduatedYear.rawValue) as! UITextField))
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.classNo.rawValue) as! UITextField))
                    self.enableTextfield(textfield:(self.container.viewWithTag(TagInt.classNo.rawValue + 11) as! UITextField))
                    self.enableTextfield(textfield:(self.container.viewWithTag(TagInt.classNo.rawValue + 12) as! UITextField))
                    self.enableTextfield(textfield:(self.container.viewWithTag(TagInt.classNo.rawValue + 21) as! UITextField))
                    self.enableTextfield(textfield:(self.container.viewWithTag(TagInt.classNo.rawValue + 22) as! UITextField))
                    self.enableTextfield(textfield:(self.container.viewWithTag(TagInt.classNo.rawValue + 31) as! UITextField))
                    self.enableTextfield(textfield:(self.container.viewWithTag(TagInt.classNo.rawValue + 32) as! UITextField))
                    break
                case .nflsSeniorALevel,
                     .nflsSeniorIB,
                     .nflsSeniorBCA:
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.schoolName.rawValue) as! UITextField))
                    self.enableTextfield(textfield:(self.container.viewWithTag(TagInt.enterYear.rawValue) as! UITextField))
                    self.enableTextfield(textfield:(self.container.viewWithTag(TagInt.graduatedYear.rawValue) as! UITextField))
                    self.enableTextfield(textfield:(self.container.viewWithTag(TagInt.classNo.rawValue) as! UITextField))
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.classNo.rawValue + 11) as! UITextField))
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.classNo.rawValue + 12) as! UITextField))
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.classNo.rawValue + 21) as! UITextField))
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.classNo.rawValue + 22) as! UITextField))
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.classNo.rawValue + 31) as! UITextField))
                    self.disableTextfield(textfield:(self.container.viewWithTag(TagInt.classNo.rawValue + 32) as! UITextField))
                    break
                }
                break
            case .basicInfo,
                 .confirmInfo,
                 .collegeInfo,
                 .workInfo,
                 .personalInfo,
                 .end:
                break
            }
            //self.fadeInOrOut(object: self.container, isIn: true)
        }
    }
    
    func loadData(data:[String:Any?]){
         DispatchQueue.main.async {
            for (index,string) in data{
                switch(index){
                case "primary_school_name",
                     "junior_school_name",
                     "senior_school_name":
                    self.setTextfieldText(tag: .schoolName, text: string as? String)
                    break
                case "primary_school_enter_year",
                     "junior_school_enter_year",
                     "senior_school_enter_year":
                    self.setTextfieldValue(tag: .enterYear, value: string as! Int)
                    break
                case "primary_school_graduated_year",
                     "junior_school_graduated_year",
                     "senior_school_graduated_year":
                    self.setTextfieldValue(tag: .graduatedYear, value: string as! Int)
                    break
                case "junior_class",
                     "senior_class":
                    self.setTextfieldValue(tag: .classNo, value: string as! Int)
                    break
                case "senior_class_11":
                    self.setTextfieldValue(tag: .enterYear, value: string as! Int, 11)
                    break
                case "senior_class_12":
                    self.setTextfieldValue(tag: .enterYear, value: string as! Int, 12)
                    break
                case "senior_class_21":
                    self.setTextfieldValue(tag: .enterYear, value: string as! Int, 21)
                    break
                case "senior_class_22":
                    self.setTextfieldValue(tag: .enterYear, value: string as! Int, 22)
                    break
                case "senior_class_31":
                    self.setTextfieldValue(tag: .enterYear, value: string as! Int, 31)
                    break
                case "senior_class_32":
                    self.setTextfieldValue(tag: .enterYear, value: string as! Int, 32)
                    break
                case "junior_school_no",
                     "primary_school_no",
                     "senior_school_no":
                    var option:Int
                    if(string is Int? || string is Int){
                        option = string as! Int
                    } else {
                        option = Int(string as! String)!
                    }
                    if (option == -1){
                        (self.container.viewWithTag(self.pickerTag) as! UIPickerView).selectRow(0,inComponent: 0, animated: true)
                        self.pickerOption = 0
                    }
                    else {
                        (self.container.viewWithTag(self.pickerTag) as! UIPickerView).selectRow(option,inComponent: 0, animated: true)
                        self.pickerOption = option
                    }
                    self.updateTextfield(step: self.currentStep, selected: option)
                    self.setPicker = true
                    break
                    //Basic-info
                case "english_name":
                    self.setTextfieldText(tag: .engName, text: string as? String)
                    break
                case "email":
                    self.setTextfieldText(tag: .email, text: string as? String)
                case "phone_domestic":
                    self.setTextfieldText(tag: .phoneIn, text: string as? String)
                    break
                case "phone_international":
                    self.setTextfieldText(tag: .phoneInter, text: string as? String)
                    break
                case "realname":
                    self.setTextfieldText(tag: .realName, text: string as? String)
                    break
                case "nickname":
                    self.setTextfieldText(tag: .nickName, text: string as? String)
                    break
                case "usedname":
                    self.setTextfieldText(tag: .usedName, text: string as? String)
                    break
                case "username":
                    self.setTextfieldText(tag: .userName, text: string as? String)
                    break
                case "birthday":
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy/MM/dd"
                    let date = dateFormatter.date(from: string as! String)!
                    (self.container.viewWithTag(TagInt.birthday.rawValue) as! UIDatePicker).setDate(date, animated: true)
                    break
                case "gender":
                    var option:Int
                    if(string is Int? || string is Int){
                        option = string as! Int
                    } else {
                        option = Int(string as! String)!
                    }
                    (self.container.viewWithTag(self.pickerTag) as! UIPickerView).selectRow(option - 1,inComponent: 0, animated: true)
                    self.pickerOption = option - 1
                    self.setPicker = true
                    break
                //college info
                case "undergraduate":
                    (self.container.viewWithTag(TagInt.undergraduateSwitch.rawValue) as! UISwitch).isOn = string as! Bool
                    self.switchChanged(switch_: (self.container.viewWithTag(TagInt.undergraduateSwitch.rawValue) as! UISwitch))
                    break
                case "undergraduate_school":
                    self.setTextfieldText(tag: .undergraduateSwitch, text: string as? String, TagInt.schoolName.rawValue)
                    break
                case "undergraduate_start":
                    self.setTextfieldText(tag: .undergraduateSwitch, text: string as? String, TagInt.enterYear.rawValue)
                    break
                case "undergraduate_end":
                    self.setTextfieldText(tag: .undergraduateSwitch, text: string as? String, TagInt.graduatedYear.rawValue)
                    break
                case "undergraduate_major":
                    self.setTextfieldText(tag: .undergraduateSwitch, text: string as? String, TagInt.major.rawValue)
                    break
                case "master":
                    (self.container.viewWithTag(TagInt.masterSwitch.rawValue) as! UISwitch).isOn = string as! Bool
                    self.switchChanged(switch_: (self.container.viewWithTag(TagInt.masterSwitch.rawValue) as! UISwitch))
                    break
                case "master_school":
                    self.setTextfieldText(tag: .masterSwitch, text: string as? String, TagInt.schoolName.rawValue)
                    break
                case "master_start":
                    self.setTextfieldText(tag: .masterSwitch, text: string as? String, TagInt.enterYear.rawValue)
                    break
                case "master_end":
                    self.setTextfieldText(tag: .masterSwitch, text: string as? String, TagInt.graduatedYear.rawValue)
                    break
                case "master_major":
                    self.setTextfieldText(tag: .masterSwitch, text: string as? String, TagInt.major.rawValue)
                    break
                case "doctor":
                    (self.container.viewWithTag(TagInt.doctorSwitch.rawValue) as! UISwitch).isOn = string as! Bool
                    self.switchChanged(switch_: (self.container.viewWithTag(TagInt.doctorSwitch.rawValue) as! UISwitch))
                    break
                case "doctor_school":
                    self.setTextfieldText(tag: .doctorSwitch, text: string as? String, TagInt.schoolName.rawValue)
                    break
                case "doctor_start":
                    self.setTextfieldText(tag: .doctorSwitch, text: string as? String, TagInt.enterYear.rawValue)
                    break
                case "doctor_end":
                    self.setTextfieldText(tag: .doctorSwitch, text: string as? String, TagInt.graduatedYear.rawValue)
                    break
                case "doctor_major":
                    self.setTextfieldText(tag: .doctorSwitch, text: string as? String, TagInt.major.rawValue)
                    break
                case "college":
                    (self.container.viewWithTag(TagInt.collegeSwitch.rawValue) as! UISwitch).isOn = string as! Bool
                    self.switchChanged(switch_: (self.container.viewWithTag(TagInt.collegeSwitch.rawValue) as! UISwitch))
                    break
                case "college_school":
                    self.setTextfieldText(tag: .collegeSwitch, text: string as? String, TagInt.schoolName.rawValue)
                    break
                case "college_start":
                    self.setTextfieldText(tag: .collegeSwitch, text: string as? String, TagInt.enterYear.rawValue)
                    break
                case "college_end":
                    self.setTextfieldText(tag: .collegeSwitch, text: string as? String, TagInt.graduatedYear.rawValue)
                    break
                case "college_major":
                    self.setTextfieldText(tag: .collegeSwitch, text: string as? String, TagInt.major.rawValue)
                    break
                case "other":
                    (self.container.viewWithTag(TagInt.otherSwitch.rawValue) as! UISwitch).isOn = string as! Bool
                    self.switchChanged(switch_: (self.container.viewWithTag(TagInt.otherSwitch.rawValue) as! UISwitch))
                    break
                case "other_school":
                    self.setTextfieldText(tag: .otherSwitch, text: string as? String, TagInt.schoolName.rawValue)
                    break
                case "other_start":
                    self.setTextfieldText(tag: .otherSwitch, text: string as? String, TagInt.enterYear.rawValue)
                    break
                case "other_end":
                    self.setTextfieldText(tag: .otherSwitch, text: string as? String, TagInt.graduatedYear.rawValue)
                    break
                case "other_major":
                    self.setTextfieldText(tag: .otherSwitch, text: string as? String, TagInt.major.rawValue)
                    break
                case "other_type":
                    self.setTextfieldText(tag: .otherSwitch, text: string as? String, TagInt.schoolType.rawValue)
                    break
                case "work_info":
                    (self.container.viewWithTag(TagInt.workType.rawValue) as! UITextView).text = string as? String
                    break
                case "personal_info":
                    (self.container.viewWithTag(TagInt.personalInfo.rawValue) as! UITextView).text = string as? String
                    break
                case "wechat":
                    self.setTextfieldText(tag: .personalInfo, text: string as? String, PersonalInfoType.wechat.rawValue)
                    break
                case "qq":
                    self.setTextfieldText(tag: .personalInfo, text: string as? String, PersonalInfoType.qq.rawValue)
                    break
                case "weibo":
                    self.setTextfieldText(tag: .personalInfo, text: string as? String, PersonalInfoType.weibo.rawValue)
                    break
                case "telegram":
                    self.setTextfieldText(tag: .personalInfo, text: string as? String, PersonalInfoType.telegram.rawValue)
                    break
                case "whatsapp":
                    self.setTextfieldText(tag: .personalInfo, text: string as? String, PersonalInfoType.whatsapp.rawValue)
                    break
                case "skype":
                    self.setTextfieldText(tag: .personalInfo, text: string as? String, PersonalInfoType.skype.rawValue)
                    break
                case "viber":
                    self.setTextfieldText(tag: .personalInfo, text: string as? String, PersonalInfoType.viber.rawValue)
                    break
                case "google_talk":
                    self.setTextfieldText(tag: .personalInfo, text: string as? String, PersonalInfoType.google_talk.rawValue)
                    break
                case "youtube":
                    self.setTextfieldText(tag: .personalInfo, text: string as? String, PersonalInfoType.youtube.rawValue)
                    break
                case "twitter":
                    self.setTextfieldText(tag: .personalInfo, text: string as? String, PersonalInfoType.twitter.rawValue)
                    break
                case "facebook":
                    self.setTextfieldText(tag: .personalInfo, text: string as? String, PersonalInfoType.facebook.rawValue)
                    break
                case "vimeo":
                    self.setTextfieldText(tag: .personalInfo, text: string as? String, PersonalInfoType.vimeo.rawValue)
                    break
                case "instagram":
                    self.setTextfieldText(tag: .personalInfo, text: string as? String, PersonalInfoType.instagram.rawValue)
                    break
                case "snapchat":
                    self.setTextfieldText(tag: .personalInfo, text: string as? String, PersonalInfoType.snapchat.rawValue)
                    break
                case "groupme":
                    self.setTextfieldText(tag: .personalInfo, text: string as? String, PersonalInfoType.groupme.rawValue)
                    break
                default:
                    break
                }
            }
            switch(self.currentStep){
            case .primaryInfo,
                 .juniorInfo,
                 .seniorInfo:
                self.pickerCheck()
                break
            default:
                break
                
            }
        }
    }
    
    @objc func buttonPressed(button:UIButton){
        disableButtons()
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
        var jsonDictionary = [String:AnyObject]()
        jsonDictionary["action"] = button.tag as AnyObject
        switch(currentStep){
        case .basicInfo:
            jsonDictionary["realname"] = self.getTextfieldText(tag: .realName)
            jsonDictionary["usedname"] = self.getTextfieldText(tag: .userName)
            jsonDictionary["phone_domestic"] = self.getTextfieldText(tag: .phoneIn)
            jsonDictionary["phone_international"] = self.getTextfieldText(tag: .phoneInter)
            jsonDictionary["username"] = self.getTextfieldText(tag: .userName)
            jsonDictionary["email"] = self.getTextfieldText(tag: .email)
            jsonDictionary["nickname"] = self.getTextfieldText(tag: .nickName)
            jsonDictionary["english_name"] = self.getTextfieldText(tag: .engName)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            jsonDictionary["birthday"] = dateFormatter.string(from: (self.container.viewWithTag(TagInt.birthday.rawValue) as! UIDatePicker).date) as AnyObject
            jsonDictionary["gender"] = String(describing:(pickerOption + 1)) as AnyObject
            break
        case .primaryInfo:
            let enumOption = PrimarySchoolType(rawValue: pickerOption)!
            jsonDictionary["primary_school_no"] = pickerOption as AnyObject
            jsonDictionary["primary_school_name"] = (self.container.viewWithTag(TagInt.schoolName.rawValue) as! UITextField).text as AnyObject
            switch(enumOption){
            case .other:
                break
            case .nflsPrimary2,
                 .nflsPrimary4:
                jsonDictionary["primary_school_enter_year"] = (self.container.viewWithTag(TagInt.enterYear.rawValue) as! UITextField).text as AnyObject
                jsonDictionary["primary_school_graduated_year"] = (self.container.viewWithTag(TagInt.graduatedYear.rawValue) as! UITextField).text as AnyObject
                jsonDictionary["primary_remark"] = (self.container.viewWithTag(TagInt.remark.rawValue) as! UITextField).text as AnyObject
                break
            }
            break
        case .juniorInfo:
            let enumOption = JuniorSchoolType(rawValue: pickerOption)!
            jsonDictionary["junior_school_no"] = pickerOption as AnyObject
            jsonDictionary["junior_remark"] = (self.container.viewWithTag(TagInt.remark.rawValue) as! UITextField).text as AnyObject
            switch(enumOption){
            case .other:
                jsonDictionary["junior_school_name"] = (self.container.viewWithTag(TagInt.schoolName.rawValue) as! UITextField).text as AnyObject
                break
            case .nflsJunior:
                jsonDictionary["junior_school_enter_year"] = (self.container.viewWithTag(TagInt.enterYear.rawValue) as! UITextField).text as AnyObject
                jsonDictionary["junior_school_graduated_year"] = (self.container.viewWithTag(TagInt.graduatedYear.rawValue) as! UITextField).text as AnyObject
                jsonDictionary["junior_class"] = (self.container.viewWithTag(TagInt.classNo.rawValue) as! UITextField).text as AnyObject
                break
            }
            break
        case .seniorInfo:
            let enumOption = SeniorSchoolType(rawValue: pickerOption)!
            jsonDictionary["senior_school_no"] = pickerOption as AnyObject
            jsonDictionary["senior_remark"] = (self.container.viewWithTag(TagInt.remark.rawValue) as! UITextField).text as AnyObject
            switch(enumOption){
            case .nflsSeniorGeneral:
                jsonDictionary["senior_school_enter_year"] = (self.container.viewWithTag(TagInt.enterYear.rawValue) as! UITextField).text as AnyObject
                jsonDictionary["senior_school_graduated_year"] = (self.container.viewWithTag(TagInt.graduatedYear.rawValue) as! UITextField).text as AnyObject
                jsonDictionary["senior_class_11"] = (self.container.viewWithTag(TagInt.classNo.rawValue+11) as! UITextField).text as AnyObject
                jsonDictionary["senior_class_12"] = (self.container.viewWithTag(TagInt.classNo.rawValue+12) as! UITextField).text as AnyObject
                jsonDictionary["senior_class_21"] = (self.container.viewWithTag(TagInt.classNo.rawValue+21) as! UITextField).text as AnyObject
                jsonDictionary["senior_class_22"] = (self.container.viewWithTag(TagInt.classNo.rawValue+22) as! UITextField).text as AnyObject
                jsonDictionary["senior_class_31"] = (self.container.viewWithTag(TagInt.classNo.rawValue+31) as! UITextField).text as AnyObject
                jsonDictionary["senior_class_32"] = (self.container.viewWithTag(TagInt.classNo.rawValue+32) as! UITextField).text as AnyObject
                
                break
            case .nflsSeniorBCA,
                  .nflsSeniorALevel,
                  .nflsSeniorIB:
                jsonDictionary["senior_school_enter_year"] = (self.container.viewWithTag(TagInt.enterYear.rawValue) as! UITextField).text as AnyObject
                jsonDictionary["senior_school_graduated_year"] = (self.container.viewWithTag(TagInt.graduatedYear.rawValue) as! UITextField).text as AnyObject
                jsonDictionary["senior_class"] = (self.container.viewWithTag(TagInt.classNo.rawValue) as! UITextField).text as AnyObject
                break
            case .other:
                jsonDictionary["senior_school_name"] = (self.container.viewWithTag(TagInt.schoolName.rawValue) as! UITextField).text as AnyObject
                break
            }
        case .collegeInfo:
            self.checkSwitchItems(jsonDictionary: &jsonDictionary, prefix: "college", tag: .collegeSwitch)
            self.checkSwitchItems(jsonDictionary: &jsonDictionary, prefix: "undergraduate", tag: .undergraduateSwitch)
            self.checkSwitchItems(jsonDictionary: &jsonDictionary, prefix: "doctor", tag: .doctorSwitch)
            self.checkSwitchItems(jsonDictionary: &jsonDictionary, prefix: "master", tag: .masterSwitch)
            self.checkSwitchItems(jsonDictionary: &jsonDictionary, prefix: "other", tag: .otherSwitch,true)
            jsonDictionary["college_remark"] = (self.container.viewWithTag(TagInt.remark.rawValue) as! UITextField).text as AnyObject
            break
        case .workInfo:
            jsonDictionary["work_info"] = (self.container.viewWithTag(TagInt.workType.rawValue) as! UITextView).text as AnyObject
            break
        case .personalInfo:
            jsonDictionary["personal_info"] = (self.container.viewWithTag(TagInt.personalInfo.rawValue) as! UITextView).text as AnyObject
            jsonDictionary["wechat"] = self.getTextfieldText(tag: .personalInfo, PersonalInfoType.wechat.rawValue)
            jsonDictionary["weibo"] = self.getTextfieldText(tag: .personalInfo, PersonalInfoType.weibo.rawValue)
            jsonDictionary["qq"] = self.getTextfieldText(tag: .personalInfo, PersonalInfoType.qq.rawValue)
            jsonDictionary["telegram"] = self.getTextfieldText(tag: .personalInfo, PersonalInfoType.telegram.rawValue)
            jsonDictionary["whatsapp"] = self.getTextfieldText(tag: .personalInfo, PersonalInfoType.whatsapp.rawValue)
            jsonDictionary["skype"] = self.getTextfieldText(tag: .personalInfo, PersonalInfoType.skype.rawValue)
            jsonDictionary["viber"] = self.getTextfieldText(tag: .personalInfo, PersonalInfoType.viber.rawValue)
            jsonDictionary["google_talk"] = self.getTextfieldText(tag: .personalInfo, PersonalInfoType.google_talk.rawValue)
            jsonDictionary["youtube"] = self.getTextfieldText(tag: .personalInfo, PersonalInfoType.youtube.rawValue)
            jsonDictionary["twitter"] = self.getTextfieldText(tag: .personalInfo, PersonalInfoType.twitter.rawValue)
            jsonDictionary["facebook"] = self.getTextfieldText(tag: .personalInfo, PersonalInfoType.facebook.rawValue)
            jsonDictionary["vimeo"] = self.getTextfieldText(tag: .personalInfo, PersonalInfoType.vimeo.rawValue)
            jsonDictionary["instagram"] = self.getTextfieldText(tag: .personalInfo, PersonalInfoType.instagram.rawValue)
            jsonDictionary["snapchat"] = self.getTextfieldText(tag: .personalInfo, PersonalInfoType.snapchat.rawValue)
            jsonDictionary["groupme"] = self.getTextfieldText(tag: .personalInfo, PersonalInfoType.groupme.rawValue)
        default:
            break
        }
        do {
            let parameters: Parameters = jsonDictionary
            let headers: HTTPHeaders = [
                "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
            ]
            Alamofire.request("https://api.nfls.io/alumni/auth/"+String(describing: self.currentStep.rawValue)+"/update", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (response) in
                switch(response.result){
                case .success(let json):
                    let messages = (json as! [String:AnyObject])["message"] as! [String]
                    self.showMessage(messages: messages, title: "信息")
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
    
    
    func checkSwitchItems(jsonDictionary:inout [String:AnyObject], prefix:String, tag:TagInt,_ other:Bool = false){
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
        
    }
    func addFormItem(rootStackView:UIStackView,type:FormType,name:String,tag:TagInt,_ addValue:Int = 0,_ data:[String] = []){
        let stackview = UIStackView()
        let label = UILabel()
        var height:CGFloat = 35
        if(type == .datePicker || type == .picker || type == .textView){
            height = 100
        }
        let constraintForStack = NSLayoutConstraint(item: stackview, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: height)
        var constraintForLabel = NSLayoutConstraint()
        if(type == .datePicker){
            constraintForLabel = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 60)
        } else {
            constraintForLabel = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 125)
        }
        
        label.text = name + "："
        label.textAlignment = .right
        
        stackview.axis = .horizontal
        stackview.addArrangedSubview(label)
        
        switch(type){
        case .textView:
            let textfield = UITextView()
            stackview.addArrangedSubview(textfield)
            textfield.tag = tag.rawValue + addValue
            textfield.frame.size.height = 100
            textfield.layer.borderColor = UIColor.gray.cgColor
            textfield.layer.borderWidth = 1.0
            textfield.layer.cornerRadius = 5.0
            break
        case .textField:
            let leftView = UILabel(frame: CGRect(x:10, y:0, width:7, height:26))
            leftView.backgroundColor = UIColor.white
            let textfield = UITextField()
            if((tag == .email) || (tag == .userName)){
                textfield.isEnabled = false
                textfield.textColor = UIColor.gray
            }
            stackview.addArrangedSubview(textfield)
            textfield.placeholder = name
            textfield.tag = tag.rawValue + addValue
            textfield.leftView = leftView
            textfield.leftViewMode = UITextFieldViewMode.always
            textfield.contentVerticalAlignment = UIControlContentVerticalAlignment.center
            textfield.layer.borderColor = UIColor.gray.cgColor
            textfield.layer.borderWidth = 1.0
            textfield.layer.cornerRadius = 5.0
            break
        case .picker:
            let picker = UIPickerView()
            stackview.addArrangedSubview(picker)
            picker.tag = pickerTag
            //let constraintForPicker = NSLayoutConstraint(item: picker, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 100)
            picker.delegate = self
            picker.dataSource = self
            picker.layer.borderColor = UIColor.gray.cgColor
            picker.layer.borderWidth = 1.0
            picker.layer.cornerRadius = 5.0
            self.pickerData = data
            break
        case .datePicker:
            let picker = UIDatePicker()
            stackview.addArrangedSubview(picker)
            picker.locale = Locale(identifier: "zh_CN")
            picker.datePickerMode = .date
            picker.layer.borderColor = UIColor.gray.cgColor
            picker.layer.borderWidth = 1.0
            picker.layer.cornerRadius = 5.0
            picker.tag = tag.rawValue
            var components = DateComponents()
            components.year = -15
            let maxDate = Calendar.current.date(byAdding: components, to: Date())
            picker.maximumDate = maxDate
            break
        case .switch_:
            let switch_ = UISwitch()
            stackview.addArrangedSubview(switch_)
            switch_.addTarget(self, action: #selector(switchChanged(switch_:)), for: .valueChanged)
            switch_.tag = tag.rawValue
            switch_.isOn = true
            break
        }
        rootStackView.addArrangedSubview(stackview)
        label.addConstraint(constraintForLabel)
        stackview.addConstraint(constraintForStack)
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
    
    func addContainerSpacing(rootStackView:UIStackView,itemNum:Int){
        rootStackView.spacing = 15
    }
    
    func textfieldOperation(tag:Int,enable:Bool){
        let textfield = (self.container.viewWithTag(tag) as! UITextField)
        if(enable){
            enableTextfield(textfield: textfield)
        } else {
            disableTextfield(textfield: textfield)
        }
    }
    func disableTextfield(textfield:UITextField){
        textfield.superview?.isHidden = true
    }
    
    func enableTextfield(textfield:UITextField){
        textfield.superview?.isHidden = false
    }
    
    
    func pickerCheck(){
        if(!self.setPicker){
            self.updateTextfield(step: self.currentStep, selected: 0)
        }
    }
    
    func setTextfieldValue(tag:TagInt,value:Int,_ addValue:Int = 0){
        (self.container.viewWithTag(tag.rawValue + addValue) as! UITextField!).text = String(describing: value)
    }
    
    func setTextfieldText(tag:TagInt,text:String?,_ addValue:Int = 0){
        (self.container.viewWithTag(tag.rawValue + addValue) as! UITextField!).text = text as String!
    }
    
    func getTextfieldText(tag:TagInt,_ addValue:Int = 0) -> AnyObject {
        return (self.container.viewWithTag(tag.rawValue + addValue) as! UITextField).text as AnyObject
    }
    
    @objc func reset(button:UIButton){
        self.initialize()
    }
    
    @objc func switchChanged(switch_:UISwitch){
        let status = switch_.isOn
        textfieldOperation(tag: (TagInt.schoolName.rawValue + switch_.tag), enable: status)
        textfieldOperation(tag: (TagInt.enterYear.rawValue + switch_.tag), enable: status)
        textfieldOperation(tag: (TagInt.graduatedYear.rawValue + switch_.tag), enable: status)
        textfieldOperation(tag: (TagInt.major.rawValue + switch_.tag), enable: status)
        if(switch_.tag == TagInt.otherSwitch.rawValue){
            textfieldOperation(tag: (TagInt.schoolType.rawValue + switch_.tag), enable: status)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fadeInOrOut(object:UIView,isIn:Bool,duration:Double = 1){
        if (isIn){
            UIView.animate(withDuration: duration, animations: {
                object.alpha = 1
            })
        }
        else{
            UIView.animate(withDuration: duration, animations: {
                object.alpha = 0
            })
        }
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
        updateTextfield(step:currentStep,selected: row)
    }
    
}
