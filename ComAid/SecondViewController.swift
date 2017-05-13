//
//  SecondViewController.swift
//  ComAid
//
//  Created by Tongchai Tonsau on 5/11/2560 BE.
//  Copyright © 2560 Tongchai Tonsau. All rights reserved.
//

import UIKit
import Charts
import FirebaseCore
import FirebaseDatabase

class SecondViewController: UIViewController {
    
    var databaseRef: FIRDatabaseReference!
    
    let date = Date()
    let formatter = DateFormatter()
    var currentDate : Int!
    
    var countTime = [Int]()
    
    @IBOutlet weak var chart: BarChartView!
    @IBOutlet weak var datePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        //Get current date and time
        formatter.dateFormat = "yyyyMMdd"
        currentDate = Int(formatter.string(from: date))
        
        let when = DispatchTime.now() + 2
        
        getData(inDate: currentDate)
        
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.updateChartData()
        }
    }
    
    func getData(inDate: Int) {
        var number: Int!
        
        //Get data from Firebase
        databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Comaid01").child(String(inDate)).observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.countTime = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            
            if snapshot.exists() {
                let temp_number = snapshot.childSnapshot(forPath: "Num").value as! Int
                number = temp_number
                
                self.databaseRef.child("Comaid01").child(String(inDate)).child("Time").observeSingleEvent(of: .value, with: { (snapshot) in
                    if number != 0
                    {
                        for i in 1...number{
                            let temp_time = snapshot.childSnapshot(forPath: String(i)).value as! String
                            
                            var offset_ch = 0
                            for ch in temp_time.characters
                            {
                                if ch == ":" {
                                    break;
                                }
                                offset_ch += 1
                            }
                            
                            let temp_index = temp_time.index(temp_time.startIndex, offsetBy: offset_ch)
                            self.countTime[Int(temp_time.substring(to: temp_index))!] += 1
                        }
                    }
                })
            }
        })
    }
    
    func updateChartData()  {
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<countTime.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(countTime[i]))
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "")
        let chartData = BarChartData(dataSet: chartDataSet)
        
        let format = NumberFormatter()
        format.numberStyle = .decimal
        let formatter = DefaultValueFormatter(formatter: format)
        chartData.setValueFormatter(formatter)
        chart.leftAxis.valueFormatter = formatter as? IAxisValueFormatter
        
        chart.data = chartData
        
        chartDataSet.colors = ChartColorTemplates.pastel()
        chart.xAxis.labelPosition = .bottom
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dateChanged(_ sender: UIDatePicker) {
        
        datePicker.isEnabled = false
        
        let componenets = Calendar.current.dateComponents([.year, .month, .day], from: sender.date)
        
        let when = DispatchTime.now() + 2
        
        var temp_date = String(describing: componenets.year!)
        
        if componenets.month! < 10 {
            temp_date += "0"
        }
        temp_date += String(describing: componenets.month!)
        
        if componenets.day! < 10 {
            temp_date += "0"
        }
        temp_date += String(describing: componenets.day!)
        
        print(temp_date)
        
        getData(inDate: Int(temp_date)!)
        
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.updateChartData()
            
            self.datePicker.isEnabled = true
        }
    }
}
