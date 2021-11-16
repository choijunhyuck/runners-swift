//
//  SettingPOController.swift
//  runners
//
//  Created by 최준혁 on 2018. 9. 5..
//  Copyright © 2018년 choirates. All rights reserved.
//

import UIKit

class SettingPOController:UIViewController{
    
    @IBOutlet weak var background: UIImageView!
    
    @IBOutlet weak var difficulty_label: UILabel!
    
    @IBOutlet weak var selected_item: UISegmentedControl!
    
    @IBAction func change_difficulty(_ sender: UISegmentedControl) {
        
        let preferences = UserDefaults.standard
        
        switch sender.selectedSegmentIndex {
            
        case 0:
            difficulty_label.text = "EASY"
            difficulty = "1"
            preferences.set(difficulty, forKey: "difficulty")
            preferences.synchronize()
            
            updateDiff(difficulty : difficulty!)
            
        case 1:
            difficulty_label.text = "NORMAL"
            difficulty = "2"
            preferences.set(difficulty, forKey: "difficulty")
            preferences.synchronize()
            
            updateDiff(difficulty : difficulty!)
            
        case 2:
            difficulty_label.text = "HARD"
            difficulty = "3"
            preferences.set(difficulty, forKey: "difficulty")
            preferences.synchronize()
            
            updateDiff(difficulty : difficulty!)
            
        default:
            difficulty_label.text = " : DIFF : "
            
        }
        
    }
    
    
    @IBAction func close_button(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    var difficulty : String?
    var uid : String?
    
    override func viewDidLoad(){
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
        uid = preferences.string(forKey: "uid")!
        difficulty = preferences.string(forKey: "difficulty")!
        
        switch difficulty {
        case "1":
            difficulty_label.text = "EASY"
            selected_item.selectedSegmentIndex = 0
            
        case "2":
            difficulty_label.text = "NORMAL"
            selected_item.selectedSegmentIndex = 1
            
        case "3":
            difficulty_label.text = "HARD"
            selected_item.selectedSegmentIndex = 2
            
        default:
            print("Failed : LOAD")
        }
        
    }
    
    func updateDiff(difficulty : String){
        
        let urlString = "http://198.13.50.247/runners/change_user_diff.php?uid=\(uid!)&difficulty=\(difficulty)"
        print(urlString)
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
            if error != nil {
                print(error!)
            } else {
                
                let preferences = UserDefaults.standard
                preferences.set(difficulty, forKey: "difficulty")
                preferences.synchronize()
                
                print("UPDATE OK")
            }
            
            }.resume()
        
        
    }
    
}
