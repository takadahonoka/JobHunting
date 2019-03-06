//
//  TalkViewController.swift
//  GpsStalker
//
//  Created by 高田穂乃花 on 2019/02/01.
//  Copyright © 2019 stalker. All rights reserved.
//

//
//  SecondViewController.swift
//  GpsStalker

import UIKit

class TalkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var talkTableView: UITableView!
    @IBOutlet weak var naviBar: UINavigationBar!
    @IBOutlet weak var talkTextField: UITextField!
    
    
    var userId = "" //ユーザーID。
    var textFieldString = "" // 文字列保存用の変数。
    var friendId = "" //フレンドID。
    var friendName = "" //フレンド名前。
    var talkList: NSArray = [] //表示リスト。
    var talkList2: [[String]] = [[]] //表示リスト2。
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //データ保存。
        let userDefaults = UserDefaults.standard
        userId = userDefaults.string(forKey: "USERID")!
        
        //友達のID取得。
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        friendId = appDelegate.frinedId ?? ""
        friendName = appDelegate.frinedName ?? ""
        naviBar.items![0].title = friendName
        
        getTalkList()
 
        //self.talkTableView.reloadData()
        
    }
    
    //トークの情報を取得。
    func getTalkList() {
        // 取得したJSONを格納する変数を定義。
        var getJson: NSDictionary!
        
        talkTableView.backgroundColor = UIColor(red: 1.0, green: 0, blue: 1.0, alpha: 0.2)
        
        // API接続先
        let urlStr = "http://localhost:8080/getTalkList/\(userId)/\(friendId)"
        
        if let url = URL(string: urlStr) {
            let req = NSMutableURLRequest(url: url)
            req.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: req as URLRequest, completionHandler: { (data, resp, err) in
                // 受け取ったdataをJSONパース、エラーならcatchへジャンプ
                do {
                    // dataをJSONパースし、変数"getJson"に格納
                    getJson = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    //print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as Any)
                    self.talkList = getJson["talklist"] as! NSArray
                    
                    DispatchQueue.main.async{
                        self.talkTableView.reloadData()
                        //タイトルを動的表示。
                        self.naviBar.items![0].title = self.friendName
                    }
                } catch {
                    print ("json error")
                    return
                }
            })
            task.resume()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return talkList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // セルを取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "talkCell") as! CustomTableViewCell2
        
        // セルに値を設定
        let item = talkList[indexPath.row]
        if let dict = item as? NSDictionary {
            cell.talkLabel.text = dict["data"] as? String
            cell.dateLabel.text = dict["insert_date"] as? String
            cell.userImageView.image = UIImage(named: "icon.png")
        }
        return cell
    }
    
    //Backボタンの処理。
    @IBAction func pushBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //送信ボタンが押された時。
    @IBAction func pushSendButton(_ sender: Any) {
 
        //「/」はまだダメ!!
        let data: String = talkTextField.text!
        let keyword_encode = data.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        print(data.urlEncoded)
        //print(data)
        
        // 取得したJSONを格納する変数を定義。
        var getJson: NSDictionary!
        
        talkTableView.backgroundColor = UIColor(red: 1.0, green: 0, blue: 1.0, alpha: 0.2)
        
        // API接続先
        let urlStr = "http://localhost:8080/insertTalkData/123-456-789/012-345-678/\(keyword_encode!)"
        
        print(urlStr)
        
        if let url = URL(string: urlStr) {
            let req = NSMutableURLRequest(url: url)
            req.httpMethod = "POST"
            let task = URLSession.shared.dataTask(with: req as URLRequest, completionHandler: { (data, resp, err) in
                // 受け取ったdataをJSONパース、エラーならcatchへジャンプ
                do {
                    // dataをJSONパースし、変数"getJson"に格納
                    getJson = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as Any)
                    let result = getJson["result"] as! String
                    
                    DispatchQueue.main.async{
                        self.talkTableView.reloadData()
                        
                        if (result == "true") {
                            self.talkTextField.text = ""
                        } else {
                            self.talkTextField.text = "失敗"
                        }
                    }
                } catch {
                    print ("json error")
                    return
                }
            })
            task.resume()
        }
    }
    
    //トークの情報を取得。
    func insertTalkData() {
    }
    
    
    
}


//エンコード。
extension String {
    
    var urlEncoded: String {
        // 半角英数字 + "/?-._~" のキャラクタセットを定義
        let charset = CharacterSet.alphanumerics.union(.init(charactersIn: "/?-._~"))
        // 一度すべてのパーセントエンコードを除去(URLデコード)
        let removed = removingPercentEncoding ?? self
        // あらためてパーセントエンコードして返す
        return removed.addingPercentEncoding(withAllowedCharacters: charset) ?? removed
    }
}
