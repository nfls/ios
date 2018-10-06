//
//  ProblemSearchController.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/9/23.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import Eureka

class ProblemSearchController: FormViewController {
    let courseProvider = CourseProvider()
    let paperProvider = PaperProvider()
    let problemProvider = ProblemProvider()
    
    enum Mode: String {
        case question = "题目"
        case paper = "往卷"
        case wrong = "错题"
    }
    let isNotPaper = Condition.function(["type"], { (form) -> Bool in
        return (form.rowBy(tag: "type") as? SegmentedRow<String>)?.value != Mode.paper.rawValue
    })
    let isNotQuestion = Condition.function(["type"], { (form) -> Bool in
        return (form.rowBy(tag: "type") as? SegmentedRow<String>)?.value != Mode.question.rawValue
    })
    override func viewDidLoad() {
        super.viewDidLoad()
        courseProvider.load {
            self.list()
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(search))
    }
    
    @objc func search() {
        switch (form.rowBy(tag: "type") as? SegmentedRow<String>)?.value {
        case Mode.paper.rawValue:
            let section = form.sectionBy(tag: "paper") as! SelectableSection<ListCheckRow<UUID>>
            if let paper = section.selectedRow()?.selectableValue {
                self.problemProvider.list(withPaper: paper) {
                    dump(self.problemProvider.list)
                }
            }
            break
        case Mode.question.rawValue:
            break
        case Mode.wrong.rawValue:
            break
        default:
            break
        }
    }
    
    func addCourse(withType type: Course.CourseType, name: String) {
        let section = SelectableSection<ListCheckRow<UUID>>(name, selectionType: .singleSelection(enableDeselection: false)) {
            $0.tag = String(describing: type)
            $0.hidden = Condition.function([], { (form) -> Bool in
                let section = form.sectionBy(tag: "course") as? SelectableSection<ListCheckRow<Int>>
                return section?.selectedRow()?.selectableValue != type.rawValue
            })
            $0.onSelectSelectableRow = { (cell, cellRow) in
                self.paperProvider.load(withCourse: cellRow.selectableValue!, completion: {
                    self.addPaperSelect()
                })
            }
        }
        
        let list = self.courseProvider.list.filter { (course) -> Bool in
            return course.type == type
        }
        
        for course in list {
            section <<< ListCheckRow<UUID>() { listRow in
                listRow.title = course.name + " (" + course.remark + ")"
                listRow.selectableValue = course.id
                listRow.value = nil

            }
        }
        
        self.form +++ section
    }
    func removePaperSelect() {
        if let section = form.sectionBy(tag: "paper"), let index = section.index {
            form.remove(at: index)
        }
    }
    func addPaperSelect() {
        self.removePaperSelect()
        let section = SelectableSection<ListCheckRow<UUID>>("试卷", selectionType: .singleSelection(enableDeselection: false)) {
            $0.tag = "paper"
            //$0.hidden = self.isQuestion
        }
        for paper in paperProvider.list {
            section <<< ListCheckRow<UUID>(paper.name) {
                $0.title = paper.name
                $0.selectableValue = paper.id
                $0.value = nil
            }
        }
        form +++ section
    }
    func addTypeSelect() {
        let options = ["IGCSE", "A-Level", "IBDP"]
        
        let section = SelectableSection<ListCheckRow<Int>>("课程", selectionType: .singleSelection(enableDeselection: false)) {
            $0.tag = "course"
        }
        
        section <<< ListCheckRow<Int>("所有") {
            $0.title = "所有"
            $0.selectableValue = 0
            $0.value = nil
            $0.hidden = self.isNotPaper
        }
        
        for (key, option) in options.enumerated() {
            section <<< ListCheckRow<Int>(option) { listRow in
                listRow.title = option
                listRow.selectableValue = key + 1
                listRow.value = nil
            }
        }
        
        section.onSelectSelectableRow = { [weak self] _, _ in
            self?.form.sectionBy(tag: String(describing: Course.CourseType.alevel))?.evaluateHidden()
            self?.form.sectionBy(tag: String(describing: Course.CourseType.igcse))?.evaluateHidden()
            self?.form.sectionBy(tag: String(describing: Course.CourseType.ibdp))?.evaluateHidden()
        }
        
        form +++ section
    }
    
    func list() {
        self.form +++ Section("类型")
            <<< SegmentedRow<String>() {
                $0.tag = "type"
                $0.options = ["题目", "往卷", "错题"]
                $0.value = "题目"
                $0.onChange({ (_) in
                    self.removePaperSelect()
                })
        }
        
        self.addTypeSelect()
        self.addCourse(withType: Course.CourseType.igcse, name: "IGCSE")
        self.addCourse(withType: Course.CourseType.alevel, name: "A-Level")
        self.addCourse(withType: Course.CourseType.ibdp, name: "IBDP")
    
        
        self.form +++ Section("题型") {$0.hidden = self.isNotQuestion}
            <<< SwitchRow() { (switchRow) in
                switchRow.title = "选择题"
                switchRow.value = true
            }
            <<< SwitchRow() { (switchRow) in
                switchRow.title = "填空题"
                switchRow.value = true
            }
            +++ Section("附加") {$0.hidden = self.isNotQuestion}
            <<< SwitchRow() { (switchRow) in
                switchRow.title = "精确搜索"
            }
            +++ Section("搜索") {$0.hidden = self.isNotQuestion}
            <<< TextAreaRow() { (textAreaRow) in
                textAreaRow.placeholder = "题面，几个词即可"
            }
            <<< ButtonRow() {(buttonRow) in
                buttonRow.title = "拍照"
        }
    }
}
