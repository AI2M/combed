//
//  ThirdViewController.swift
//  ComAid
//
//  Created by Tongchai Tonsau on 5/11/2560 BE.
//  Copyright © 2560 Tongchai Tonsau. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ThirdViewController: UIViewController {
    @IBOutlet weak var SSID: UITextField!
    @IBOutlet weak var PASS: UITextField!
    
    
    @IBOutlet weak var STATUS: UIButton!
    @IBOutlet weak var navi: UINavigationBar!
    
    var ssid :String!
    var pass :String!
    var status :Int!
    
    let date = Date()
    let formatter = DateFormatter()
    let formatter2 = DateFormatter()
    var currentDate : Int!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        STATUS.backgroundColor = UIColor.red
        STATUS.titleLabel?.text = "Checking status....."
        formatter.dateFormat = "yyyyMMdd"
        formatter2.dateFormat = "yyy - MM - dd"
        let result = formatter2.string(from: date)
        currentDate = Int(formatter.string(from: date))
        navi.topItem?.title = result
        GetData()
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.SSID.text = self.ssid
            self.PASS.text = self.pass
            if self.status == 1
            {
                self.STATUS.backgroundColor = UIColor.green
                self.STATUS.titleLabel?.text = "Now Online !"
            }
            else
            {
                self.STATUS.backgroundColor = UIColor.red
                self.STATUS.titleLabel?.text = "Now Offline !"
            }
        }



        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func GetData(){
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Comaid01").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let getpass = snapshot.childSnapshot(forPath: "PASSWORD").value as! String
            self.pass = getpass
            let getssid = snapshot.childSnapshot(forPath: "SSID").value as! String
            self.ssid = getssid
            let getstatus = snapshot.childSnapshot(forPath: "STATUS").value as! Int
            self.status = getstatus
           
            
            
        
            
        })
    }
    
    @IBAction func Update(_ sender: Any) {
        var ref : FIRDatabaseReference!
        let newSSID = SSID.text as AnyObject
        let newPASS = PASS.text as AnyObject
        ref = FIRDatabase.database().reference()
        ref.child("Comaid01").child("PASSWORD").setValue(newPASS)
        ref.child("Comaid01").child("SSID").setValue(newSSID)
        ref.child("Comaid01").child("UPDATE").setValue(1)
        ref.child("Comaid01").child("STATUS").setValue(0)
        STATUS.backgroundColor = UIColor.red
        STATUS.titleLabel?.text = "Checking status....."

        
    }
    
    @IBAction func CheckStatus(_ sender: Any) {
        var ref : FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        ref.child("Comaid01").child("STATUS").setValue(0)
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.GetData()
            let when = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: when) {
                if self.status == 1
                {
                    self.STATUS.backgroundColor = UIColor.green
                    self.STATUS.titleLabel?.text = "Now Online !"
                }
                else
                {
                    self.STATUS.backgroundColor = UIColor.red
                    self.STATUS.titleLabel?.text = "Now Offline !"
                }
                
            }
            
            
        }
        

        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }

 

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
