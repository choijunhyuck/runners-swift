//
//  ViewController.swift
//  runners
//
//  Created by 최준혁 on 2018. 9. 1..
//  Copyright © 2018년 choirates. All rights reserved.
//

import UIKit
import SystemConfiguration

class ViewController: UIViewController {
    
    @IBOutlet weak var background: UIImageView!
    
    @IBAction func disposable_pop_button(_ sender: Any) {
        
        let alertController = UIAlertController(title: "일회용 로그인", message: "RUNNERS는 회원가입 없이 로그인하여 즐길 수 있습니다.", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func tappedFacebookLoginButton(_ sender: Any) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                // if user cancel the login
                if (result?.isCancelled)!{
                    return
                }
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                }
            }
        }
    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    //everything works print the user data
                    
                    if let data = result as? [String:Any] {
                        
                        let uid = String(describing: data["id"]!)
                        let email = String(describing: data["email"]!)
                        let name = "\(data["last_name"]!)\(data["first_name"]!)"
                        let profileImg = "http://graph.facebook.com/\(uid)/picture?type=large"
                        
                        let gender = "deprecated"
                        let link = "deprecated"
                        
                        //SAVE INFORMATION TO IPHONE
                        let preferences = UserDefaults.standard
                        preferences.set(uid, forKey: "uid")
                        preferences.set(email, forKey: "email")
                        preferences.set(name, forKey: "name")
                        preferences.set(profileImg, forKey: "profileImg")
                        preferences.synchronize()
                        
                        //SAVE INFORMATION TO DATABASE
                        self.uploadInformation(uid: uid, email: email, name: name, profileImg: profileImg, gender: gender, link: link)
                        
                    }
                    
                }
            })
        }
    }
    
    func uploadInformation(uid : String, email : String, name : String, profileImg : String,
        gender : String, link : String){
        
        let url = URL(string: "http://198.13.50.247/runners/register.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "uid=\(uid)&email=\(email)&name=\(name)&gender=\(gender)&link=\(link)&profile_img=\(profileImg)"
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
            
            if responseString!.range(of:"User") != nil {
            
                let storyBoard: UIStoryboard = UIStoryboard(name: "Hub", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "HubController")
                self.present(newViewController, animated: true, completion: nil)
                
            } else {
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "Hub", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "HubController")
                self.present(newViewController, animated: true, completion: nil)
                
            }
            
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if(!isInternetAvailable()){
            
            let alertController = UIAlertController(title: "경고", message: "RUNNERS는 인터넷 연결이 필요합니다", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
        if(FBSDKAccessToken.current() != nil){
            let storyBoard: UIStoryboard = UIStoryboard(name: "Hub", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "HubController")
            self.present(newViewController, animated: true, completion: nil)
        }
        }
        
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

