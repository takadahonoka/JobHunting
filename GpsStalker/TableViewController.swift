//
//  TableViewController.swift
//  GpsStalker
//
//  Created by 高田穂乃花 on 2019/02/01.
//  Copyright © 2019 stalker. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    // cellのlabelに書く文字列
    let name1: [String] = ["aaa", "bbb", "ccc"]
    let name2: [String] = ["ddd", "eee", "fff"]
    
    // 遷移先のViewControllerに渡す変数
    var giveData: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // sectionの数を返す関数
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // sectionごとのcellの数を返す関数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return name1.count
        } else if section == 1 {
            return name2.count
        } else {
            return 0
        }
    }
    
    // sectionの高さを返す関数
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    // sectionに載せる文字列を返す関数
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "seciton\(section)"
    }
    
    // cellの情報を書き込む関数
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! TalkViewController
        
        // ここでcellのlabelに値を入れています。
        if indexPath.section == 0 {
            cell.name.text = name1[indexPath.item]
        } else {
            cell.name.text = name2[indexPath.item]
        }
        
        return cell
    }
    
    // cellが押されたときに呼ばれる関数
    // 画面遷移の処理もここで書いている
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 押されたときのcellのlabelの文字列をViewControllerに渡したいので、一旦、giveDataに入れとく
        if indexPath.section == 0 {
            giveData = name1[indexPath.item]
        } else {
            giveData = name2[indexPath.item]
        }
        // Segueを使った画面遷移を行う関数
        performSegue(withIdentifier: "Segue", sender: nil)
    }
    
    // 遷移先のViewControllerにデータを渡す関数
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Segue" {
            let vc = segue.destination as! TalkViewController
            vc.receiveData = giveData
        }
    }
    
}
