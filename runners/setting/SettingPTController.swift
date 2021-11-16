//
//  SettingPTController.swift
//  runners
//
//  Created by 최준혁 on 2018. 9. 6..
//  Copyright © 2018년 choirates. All rights reserved.
//

import UIKit

class SettingPTController:UIViewController{
    
    @IBOutlet weak var background: UIImageView!
    
    @IBOutlet weak var facebook_image_view: UIImageView!
    
    @IBAction func logout_button(_ sender: Any) {
        
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController")
        self.present(newViewController, animated: true, completion: nil)
        
    }
    
    var profileImgUrl : String?

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
        
        let preferences = UserDefaults.standard
        profileImgUrl = preferences.string(forKey: "profileImg")

        facebook_image_view.layer.cornerRadius = 8.0
        facebook_image_view.clipsToBounds = true
        
        if let url = URL(string: profileImgUrl!) {
            facebook_image_view.contentMode = .scaleAspectFit
            downloadImage(from: url)
        }

    }
    
    func downloadImage(from profileImgUrl: URL) {
        
        print("Download Started")
        getData(from: profileImgUrl) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? profileImgUrl.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.facebook_image_view.image = UIImage(data: data)
            }
        }
    }

    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
}
