//
//  ThirdViewController.swift
//  GpsStalker
//
//  Created by 高田穂乃花 on 2019/01/26.
//  Copyright © 2019 stalker. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController{
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var telLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //データ保存。
        let userDefaults = UserDefaults.standard
        nameLabel.text = userDefaults.string(forKey: "USERNAME")
        mailLabel.text = userDefaults.string(forKey: "USERMAIL")
        telLabel.text = userDefaults.string(forKey: "USERTEL")
        let icon02 = UIImage(named:"icon02")!
        iconImageView.image = icon02
    }
    
}
