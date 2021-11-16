//
//  SafetyController.swift
//  runners
//
//  Created by 최준혁 on 2018. 9. 5..
//  Copyright © 2018년 choirates. All rights reserved.
//

import UIKit

class SafetyController:UIViewController{

    @IBAction func close_button(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
    }
    
    @objc func backAction(){
        //print("Back Button Clicked")
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
