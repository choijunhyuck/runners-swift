//
//  ResultController.swift
//  runners
//
//  Created by 최준혁 on 2018. 9. 8..
//  Copyright © 2018년 choirates. All rights reserved.
//


import UIKit

class ResultController:UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func close_button(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Hub", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "HubController")
        self.present(newViewController, animated: true, completion: nil)
        
    }
    
    var list:[MyStruct] = [MyStruct]()
    
    struct MyStruct
    {
        
        var repeatCount = ""
        var pointAmount = ""
        var time = ""
        var distance = ""
        var bonus = ""
        var speed = ""
        var created_at = ""
        
        init(_ data:NSDictionary)
        {
            
            if let add = data["repeat"] as? String
            {
                self.repeatCount = add
            }
            if let add = data["pointAmount"] as? String
            {
                self.pointAmount = add
            }
            if let add = data["time"] as? String
            {
                self.time = add
            }
            if let add = data["distance"] as? String
            {
                self.distance = add
            }
            if let add = data["bonus"] as? String
            {
                self.bonus = add
            }
            if let add = data["speed"] as? String
            {
                self.speed = add
            }
            if let add = data["created_at"] as? String
            {
                self.created_at = add
            }
            
        }
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
        uid = preferences.string(forKey: "uid")!
        
        let url = "http://198.13.50.247/runners/export_user_result.php?uid=\(uid!)"
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        collectionView.collectionViewLayout = layout
        
        
        get_data(url)
    }
    
    func get_data(_ link:String)
    {
        let url:URL = URL(string: link)!
        let session = URLSession.shared
        
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            self.extract_data(data)
            
        })
        
        task.resume()
    }
    
    func extract_data(_ data:Data?)
    {
        let json:Any?
        if(data == nil)
        {
            return
        }
        
        do
        {
            json = try JSONSerialization.jsonObject(with: data!, options: [])
        }
        catch
        {
            return
        }
        
        
        guard let data_array = json as? NSArray else
        {
            return
        }
        
        for i in 0 ..< data_array.count
        {
            if let data_object = data_array[i] as? NSDictionary
            {
                list.append(MyStruct(data_object))
            }
        }
        
        refresh_now()
        
    }
    
    func refresh_now()
    {
        DispatchQueue.main.async (
            execute:
            {
                self.collectionView.reloadData()
        }
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        
        
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 3
        
        
        cell.text.text = list[indexPath.row].created_at
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
        //CLICKED CELL LISTENER
        repeatCount = list[indexPath.row].repeatCount
        pointAmount = list[indexPath.row].pointAmount
        time = list[indexPath.row].time
        distance = list[indexPath.row].distance
        bonus = list[indexPath.row].bonus
        speed = list[indexPath.row].speed
        
        let preferences = UserDefaults.standard
        
        if(preferences.string(forKey: "repeat") != nil){
            preferences.removeObject(forKey: "repeat")
            preferences.removeObject(forKey: "pointAmount")
            preferences.removeObject(forKey: "time")
            preferences.removeObject(forKey: "distance")
            preferences.removeObject(forKey: "bonus")
            preferences.removeObject(forKey: "speed")
        }
        
        preferences.set(repeatCount, forKey: "repeat")
        preferences.set(pointAmount, forKey: "pointAmount")
        preferences.set(time, forKey: "time")
        preferences.set(distance, forKey: "distance")
        preferences.set(bonus, forKey: "bonus")
        preferences.set(speed, forKey: "speed")
        preferences.synchronize()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 192, height: 320)
    }
    
    
}
