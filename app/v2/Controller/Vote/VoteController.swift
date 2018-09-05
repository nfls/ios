//
//  VoteController.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/9/2.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import MarkdownView

class VoteController: UIViewController {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var markdownView: MarkdownView!
    
    let provider = VoteProvider()
    
    override func viewDidLoad() {
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.provider.list({ (_) in
            self.pickerView.reloadAllComponents()
            self.loadData(id: self.provider.list[0].id)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController!.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "投票", style: .plain, target: self, action: #selector(vote))
    }
    
    @objc func vote() {
        self.performSegue(withIdentifier: "showSubmit", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! VoteSubmitController
        destination.provider = self.provider
    }
    
    func loadData(id: UUID) {
        self.provider.detail(id: id, { (_) in
            self.markdownView.load(markdown: self.provider.detail?.content ?? "", enableImage: true)
        })
    }
}

extension VoteController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return provider.list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return provider.list[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.loadData(id: provider.list[row].id)
    }
}
