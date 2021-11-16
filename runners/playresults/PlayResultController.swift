//
//  PlayResultController.swift
//  runners
//
//  Created by 최준혁 on 2018. 9. 16..
//  Copyright © 2018년 choirates. All rights reserved.
//

import UIKit

class PlayResultController:UIViewController{
    
    @IBOutlet weak var repeat_view: UILabel!
    
    @IBOutlet weak var point_view: UILabel!
    
    @IBOutlet weak var time_view: UILabel!
    
    @IBOutlet weak var distance_view: UILabel!
    
    @IBOutlet weak var bonus_view: UILabel!
    
    @IBOutlet weak var speed_view: UILabel!
    
    @IBAction func close_button(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Hub", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "HubController")
        self.present(newViewController, animated: true, completion: nil)
        
    }
    
    var uid : String?
    var repeatCount : String?
    var pointAmount : String?
    var time : String?
    var distance : String?
    var bonus : String?
    var speed : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let preferences = UserDefaults.standard
        uid = preferences.string(forKey: "uid")
        repeatCount = preferences.string(forKey: "repeat")
        pointAmount = preferences.string(forKey: "pointAmount")
        time = preferences.string(forKey: "time")
        distance = preferences.string(forKey: "distance")
        bonus = preferences.string(forKey: "bonus")
        speed = preferences.string(forKey: "speed")
        
        repeat_view.text = "REPEAT \(repeatCount!) 달성"
        point_view.text = pointAmount
        time_view.text = time
        distance_view.text = distance
        bonus_view.text = bonus
        speed_view.text = speed
        
        storeResult(uid: uid!, repeatCount: repeatCount!, point: pointAmount!, time: time!, distance: distance!, bonus: bonus!, speed: speed!)
    }
    
    func storeResult(uid:String, repeatCount:String, point:String, time:String, distance:String, bonus:String, speed:String){
        
        let url = URL(string: "http://198.13.50.247/runners/register_result.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "uid=\(uid)&repeat=\(repeatCount)&point=\(point)&time=\(time)&distance=\(distance)&bonus=\(bonus)&speed=\(speed)"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response!)")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString!)")
            
        }
        task.resume()
        
    }
    
}
