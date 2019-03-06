//
//  CustomTableViewCell2.swift
//  GpsStalker
//
//  Created by 高田穂乃花 on 2019/03/01.
//  Copyright © 2019 stalker. All rights reserved.
//

import UIKit

class CustomTableViewCell2: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var talkLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    /// 画像・タイトル・説明文を設定するメソッド
    func setCell(imageName: String, talk: String, date: String) {
        userImageView.image = UIImage(named: "icon.png")
        talkLabel.text = talk
        dateLabel.text = date
    }
    
}
