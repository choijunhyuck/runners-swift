//
//  RecordController.swift
//  runners
//
//  Created by 최준혁 on 2018. 9. 6..
//  Copyright © 2018년 choirates. All rights reserved.
//

import UIKit

class RecordController:UIViewController{
    
    @IBOutlet weak var point_view: UILabel!
    
    @IBOutlet weak var distance_view: UILabel!
    
    @IBOutlet weak var time_view: UILabel!
    
    @IBOutlet weak var speed_view: UILabel!
    
    @IBOutlet weak var repeat_view: UILabel!
    
    var uid : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let preferences = UserDefaults.standard
        uid = preferences.string(forKey: "uid")!
        
        ParseData()
        
    }
    
    func ParseData(){
        
        guard let url = URL(string: "http://198.13.50.247/runners/export_user_record.php?uid=\(uid!)") else {return}
       
        let session = URLSession.shared
        
        session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error ?? "")
            }
            if data != nil {
                do{
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)
                    
                    guard let idk = json as? [Dictionary<String, Any>] else {return}
                    
                    for data: Dictionary<String, Any> in idk{
                        
                        /*
                        if let address = data["address"] as? Dictionary<String, Any>{
                            //here the data in address: { .. } is available
                            //for example
                            print(address["city"] ?? "")
                        }
                        */
                        
                        let pointAmount = data["pointAmount"] ?? ""
                        let distance = data["distance"] ?? ""
                        let time = data["time"] ?? ""
                        let speed = data["speed"] ?? ""
                        let repeatCount = data["repeat"] ?? ""
                        
                        DispatchQueue.main.async() {
                            
                            self.point_view.text = "\(pointAmount)"
                            self.distance_view.text = "\(distance)"
                            self.time_view.text = "\(time)"
                            self.speed_view.text = "\(speed)"
                            self.repeat_view.text = "\(repeatCount)"
                        }
                        
                    }
                    
                }
                catch{
                    print(error)
                }
            }
            }.resume()
        
    }
    
}
