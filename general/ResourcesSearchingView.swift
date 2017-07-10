//
//  ResourcesSearchingView.swift
//  
//
//  Created by hqy on 2017/6/26.
//
//

import Foundation
import UIKit

class ResourcesSearchingViewController:UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate{
    let ID = "Cell"
    let courses = ["IGCSE","IB","A-Level"]
    let subjectsForIGCSE = ["化学","历史","商务","数学","物理","经济","英语"]
    let subjectsForIB = ["语文A","英语B","经济","历史","商务","商务","经济","数学","音乐"]
    let years = [1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017]
    let seasons = ["春","夏","冬"]
    
    @IBOutlet weak var pickerview: UIPickerView!
    //let subjectsForALevel = ["","","","","",]
    var count:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerview.dataSource=self
        pickerview.delegate=self
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: ID, for: indexPath as IndexPath)
        /*
        cell.textLabel!.text = "\(types[indexPath.row]) - \(titles[indexPath.row])"
        cell.detailTextLabel!.text = "\(times[indexPath.row])\n\(details[indexPath.row])"
        cell.detailTextLabel!.lineBreakMode = .byWordWrapping
        cell.detailTextLabel!.numberOfLines = 0
        cell.detailTextLabel!.sizeToFit()
         */
        cell.sizeToFit()
        
        return cell
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch(component){
        case 0:
            return courses.count
        case 1:
            return subjectsForIB.count
        case 2:
            return years.count
        case 3:
            return seasons.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch(component){
        case 0:
            return courses[row]
        case 1:
            return subjectsForIB[row]
        case 2:
            return String(years[row])
        case 3:
            return seasons[row]
        default:
            return ""
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        dump(row)
        //updateTextfield(step:currentStep,selected: row)
    }
}
