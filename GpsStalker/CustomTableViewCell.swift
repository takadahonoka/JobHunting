//
//  CustomTableViewCell.swift
//  GpsStalker
//
//  Created by 高田穂乃花 on 2019/02/25.
//  Copyright © 2019 stalker. All rights reserved.
//

//Cellカスタムクラス。

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var friendImageView: UIImageView!
    
    @IBOutlet weak var friendNameText: UILabel!
    
    @IBOutlet weak var friendLogText: UILabel!
    
    /// 画像・タイトル・説明文を設定するメソッド
    func setCell(imageName: String, titleText: String, descriptionText: String) {
        friendImageView.image = UIImage(named: "icon.png")
        friendNameText.text = titleText
        friendLogText.text = descriptionText
    }
    
}
