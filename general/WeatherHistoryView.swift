//
//  WeatherHistoryView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/8/16.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import Charts

class WeatherHistoryViewController:UIViewController{
    
    
    
    @IBOutlet var chart: LineChartView!
    
    var months: [String]! = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chart.noDataText = "Ass we can!"
        var dataEntries: [ChartDataEntry] = []
        let value = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        for i in 0..<months.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: value[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "Units Sold")
        let chartData = LineChartData(dataSet: chartDataSet)
        chart.data = chartData
        chart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
    }
}
