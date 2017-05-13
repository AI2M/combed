//
//  FirstViewController.swift
//  ComAid
//
//  Created by Tongchai Tonsau on 5/11/2560 BE.
//  Copyright © 2560 Tongchai Tonsau. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseDatabase

class FirstViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var TableViews: UITableView!
    
    @IBOutlet weak var navi: UINavigationBar!
    let date = Date()
    let formatter = DateFormatter()
    let formatter2 = DateFormatter()
    var currentDate : Int!
    var DataTime :[String] = []
    var Number : Int!
    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "yyyyMMdd"
        formatter2.dateFormat = "yyyy - MM - dd"
        let result = formatter2.string(from: date)
        currentDate = Int(formatter.string(from: date))
        navi.topItem?.title = result

        GetNum()
        let when = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.GetData()
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when) {
                print(self.DataTime)
                self.TableViews.reloadData()
            }
        }
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        TableViews.addSubview(refreshControl)
        
        // Do any additional setup after loading the view.
    }
    func refresh(sender:AnyObject) {
        GetNum()
        let when = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.GetData()
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when) {
                print(self.DataTime)
                self.TableViews.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataTime.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        
        cell.textLabel?.text = ("Job: " + "\(indexPath.row+1)")
        cell.detailTextLabel?.text = ("Time -> " + DataTime[indexPath.row])
        return cell
    }
    func GetNum(){
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Comaid01").child(String(currentDate)).observeSingleEvent(of: .value, with: { (snapshot) in
            let number  = snapshot.childSnapshot(forPath: "Num").value as! Int
            self.Number = number
            
        })
    }
    
    func GetData(){
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Comaid01").child(String(currentDate)).child("Time").observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.DataTime.removeAll()
            //print(snapshot)
            if self.Number != 0
            {
                for i in 1...self.Number{
                    let time = snapshot.childSnapshot(forPath: String(i)).value as! String
                    self.DataTime.append(time)
                }
            }
            
            
        })
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}
