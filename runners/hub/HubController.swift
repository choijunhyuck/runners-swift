//
//  HubController.swift
//  runners
//
//  Created by 최준혁 on 2018. 9. 3..
//  Copyright © 2018년 choirates. All rights reserved.
//

import UIKit
import SystemConfiguration

class HubController: UIViewController {
    
    @IBOutlet weak var background: UIImageView!
    
    @IBOutlet weak var weather_tap: UIImageView!
    
    @IBOutlet weak var community_tap: UIImageView!
    
    @IBOutlet weak var safetyFrame_tap: UIImageView!
    
    @IBOutlet weak var setting_tap: UIImageView!
    
    @IBOutlet weak var challenge_tap: UIImageView!
    
    @IBAction func play_button(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Play", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "PlayController")
        self.present(newViewController, animated: true, completion: nil)
        
    }
    
    var uid : String?
    var email : String?
    var name : String?
    var profileImg : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //SET TIME
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        
        if(hour < 7 || hour > 18){
            background.image = UIImage(named: "main_screen_night")
        }else if(hour > 12){
            background.image = UIImage(named: "main_screen_noon")
        }else{
            background.image = UIImage(named: "main_screen")
        }
        //
        
        //WEATHER && COMMUNITY TAP BUTTON CLICK LISTENER
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HubController.connected(_:)))
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(HubController.connected2(_:)))
        
        weather_tap.isUserInteractionEnabled = true
        weather_tap.addGestureRecognizer(tapGestureRecognizer)
        
        community_tap.isUserInteractionEnabled = true
        community_tap.addGestureRecognizer(tapGestureRecognizer2)
        
        //SAFETY:FRAME && SETTING TAP BUTTON CLICK LISTENER
        let tapGestureRecognizer3 = UITapGestureRecognizer(target: self, action: #selector(HubController.connected3(_:)))
        let tapGestureRecognizer4 = UITapGestureRecognizer(target: self, action: #selector(HubController.connected4(_:)))
        
        safetyFrame_tap.isUserInteractionEnabled = true
        safetyFrame_tap.addGestureRecognizer(tapGestureRecognizer3)
        
        setting_tap.isUserInteractionEnabled = true
        setting_tap.addGestureRecognizer(tapGestureRecognizer4)
        
        //CHALLENGE TAP BUTTON CLICK LISTENER
        let tapGestureRecognizer5 = UITapGestureRecognizer(target: self, action: #selector(HubController.connected5(_:)))
        
        challenge_tap.isUserInteractionEnabled = true
        challenge_tap.addGestureRecognizer(tapGestureRecognizer5)
        
        
        //GET USER INFORMATION && CHECK ACCESSTOKEN
        let preferences = UserDefaults.standard
        let loginManager = FBSDKLoginManager()

        if (preferences.object(forKey:"uid") == nil || FBSDKAccessToken.current() == nil){
            
            loginManager.logOut()
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController")
            self.present(newViewController, animated: true, completion: nil)
            
        } else {
            
            uid = preferences.string(forKey: "uid")!
            email = preferences.string(forKey: "email")!
            name = preferences.string(forKey: "name")!
            profileImg = preferences.string(forKey: "profileImg")!
            
            getUserOption(uid : uid!)
            
        }
        
    }
    
    @objc func connected(_ sender:AnyObject){
        guard let url = URL(string: "https://www.google.com/search?client=safari&rls=en&q=weather") else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @objc func connected2(_ sender:AnyObject){
        
        guard let url = URL(string: "https://www.facebook.com/RUNNERS000") else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
    }
    
    @objc func connected3(_ sender:AnyObject){
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Safety", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "SafetyController")
        self.present(newViewController, animated: true, completion: nil)
        
    }
    
    @objc func connected4(_ sender:AnyObject){
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Setting", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "SettingController")
        self.present(newViewController, animated: true, completion: nil)
        
    }
    
    @objc func connected5(_ sender:AnyObject){
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Challenge", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "RootController")
        self.present(newViewController, animated: true, completion: nil)
        
    }
    
    func getUserOption(uid : String){
        
        let urlString = "http://198.13.50.247/runners/export_user_option.php?uid=\(uid)"
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
            if error != nil {
                print(error!)
            } else {
                do {
                    
                    let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                    let currentConditions = parsedData["user"] as! [String:Any]
                
                    let difficulty = currentConditions["difficulty"]! as? String
                    let ticket = currentConditions["ticket"]! as? String
                    
                    let preferences = UserDefaults.standard
                    preferences.set(difficulty, forKey: "difficulty")
                    preferences.set(ticket, forKey: "ticket")
                    preferences.synchronize()
                    
                    print("OPTION OK")
                    
                } catch let error as NSError {
                    print(error)
                }
            }
            
            }.resume()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    
}
