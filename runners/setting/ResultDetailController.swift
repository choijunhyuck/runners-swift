//
//  ResultDetailController.swift
//  runners
//
//  Created by 최준혁 on 2018. 9. 11..
//  Copyright © 2018년 choirates. All rights reserved.
//

import UIKit

class ResultDetailController:UIViewController{
    
    @IBOutlet weak var repeat_view: UILabel!
    
    @IBOutlet weak var point_view: UILabel!
    
    @IBOutlet weak var time_view: UILabel!
    
    @IBOutlet weak var distance_view: UILabel!
    
    @IBOutlet weak var bonus_view: UILabel!
    
    @IBOutlet weak var speed_view: UILabel!
    
    var repeatCount : String?
    var pointAmount : String?
    var time : String?
    var distance : String?
    var bonus : String?
    var speed : String?
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        
        let preferences = UserDefaults.standard
        repeatCount = preferences.string(forKey: "repeat")
        pointAmount = preferences.string(forKey: "pointAmount")
        time = preferences.string(forKey: "time")
        distance = preferences.string(forKey: "distance")
        bonus = preferences.string(forKey: "bonus")
        speed = preferences.string(forKey: "speed")
        
        repeat_view.text = repeatCount
        point_view.text = pointAmount
        time_view.text = time
        distance_view.text = distance
        bonus_view.text = bonus
        speed_view.text = speed
        
    }
    
}
