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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(submit))
        
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
        self.provider?.submit(options: values, {(message) in
            SCLAlertView().showInfo("提示", subTitle: message)
        })
        self.navigationController?.popViewController(animated: true)
    }
}
