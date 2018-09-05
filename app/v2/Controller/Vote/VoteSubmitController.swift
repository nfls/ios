//
//  VoteSubmitController.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/9/3.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import Eureka
import SCLAlertView

class VoteSubmitController: FormViewController {
    public var provider: VoteProvider? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for option in (self.provider!.detail!.options)! {
            self.form +++ SelectableSection<ListCheckRow<Int>>(option.text, selectionType: .singleSelection(enableDeselection: true))
            for (index, item) in option.options.enumerated() {
                self.form.last! <<< ListCheckRow<Int> { (listCheckRow) in
                    listCheckRow.selectableValue = index
                    listCheckRow.title = item
                    listCheckRow.value = nil
                }
            }
        }
        self.provider?.check({(string) in
            if let message = string {
                SCLAlertView().showError("错误", subTitle: message)
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "提交", style: .done, target: self, action: #selector(self.submit))
            }
        })
    }
    
    @objc func submit() {
        var values: [Int] = []
        for section in self.form.allSections {
            if let section = section as? SelectableSection<ListCheckRow<Int>> {
                let row = section.selectedRow()
                if let value = row?.selectableValue {
                    values.append(row?.selectableValue ?? 0)
                } else {
                    SCLAlertView().showError("表格不完整", subTitle: "请完成所有选项")
                    return
                }
            }
        }
        let confirm = SCLAlertView()
        confirm.addButton("确认") {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.provider?.submit(options: values, {(code) in
                SCLAlertView().showSuccess("投票成功", subTitle: "您已投票成功。该查询码可用于查询自己的投票信息。请注意保护好该查询码，不要告诉他人: " + code)
                self.navigationController?.popViewController(animated: true)
            })
        }
        confirm.showNotice("提交确认", subTitle: "提交后，您将无法修改您的选择。您确认要提交吗？", closeButtonTitle: "取消")
    }
}
