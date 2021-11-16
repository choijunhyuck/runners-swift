//
//  ChallengeController.swift
//  runners
//
//  Created by 최준혁 on 2018. 9. 11..
//  Copyright © 2018년 choirates. All rights reserved.
//

import UIKit

class ChallengeController:UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var ticket_view: UIImageView!
    
    @IBAction func close_button(_ sender: UIButton) {

        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    var list:[MyStruct] = [MyStruct]()
    
    struct MyStruct
    {
        
        var salt = ""
        
        init(_ data:NSDictionary)
        {
            
            if let add = data["salt"] as? String
            {
                self.salt = add
            }
            
        }
    }
    
    var uid : String?
    var ticket : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let preferences = UserDefaults.standard
        uid = preferences.string(forKey: "uid")!
        ticket = preferences.string(forKey: "ticket")!

        let url = "http://198.13.50.247/runners/export_challenge.php?uid=\(uid!)"
        
        print(url)
        
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell2", for: indexPath) as! CustomCell2
        
        cell.layer.cornerRadius = 3
        
        
        /*list[indexPath.row].created_at*/
        
        cell.count.text = list[indexPath.row].salt
        
        switch list[indexPath.row].salt {
        case "A":
            cell.count.text = "== 1 =="
            cell.text.text = "퀵 실버"
            cell.detail.text = "시속 3억 이상"
        case "B":
            cell.count.text = "== 2 =="
            cell.text.text = "모순덩어리"
            cell.detail.text = "오차보너스 250 이상"
        case "C":
            cell.count.text = "== 3 =="
            cell.text.text = "부상!"
            cell.detail.text = "100초 이상에서 게임중단"
        case "D":
            cell.count.text = "== 4 =="
            cell.text.text = "아슬아슬"
            cell.detail.text = "탈출 직전 게임오버"
        case "E":
            cell.count.text = "== 5 =="
            cell.text.text = "케냐인"
            cell.detail.text = "시속보너스 50 이상"
        default:
            print("ERROR WITH LOAD TICKET")
        }
        
        var ticketImage: UIImage

        switch ticket {
        case "0":
            
            print("HAVE NO TICKET")
        case "1":
            
            ticketImage = UIImage(named: "ticket_bronze_flat")!
            ticket_view.image = ticketImage
            
        case "2":
            
            ticketImage = UIImage(named: "ticket_silver_flat")!
            ticket_view.image = ticketImage
            
        case "3":
            
            ticketImage = UIImage(named: "ticket_gold_flat")!
            ticket_view.image = ticketImage
            
        default:
            print("ERROR WITH LOAD TICKET")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 192, height: 192)
    }
    
}
