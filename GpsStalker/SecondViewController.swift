//
//  SecondViewController.swift
//  GpsStalker

import UIKit

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    /// 画像
    let imageNames = ["icon.png", "icon.png", "icon.png", "icon.png"]
    
    @IBOutlet weak var friendTableView: UITableView!
    @IBOutlet weak var naviBar: UINavigationBar!
    
    var friendList: NSArray = [] //表示リスト。
    var titleName: String = "" //タイトル表示。
    var userId: String = "" //ユーザーID。
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        //データ保存。
        let userDefaults = UserDefaults.standard
        userId = userDefaults.string(forKey: "USERID")!
        
        getFamiryList()
    }
    
    
    //家族の情報を取得。
    func getFamiryList() {
        // 取得したJSONを格納する変数を定義。
        var getJson: NSDictionary!
    
        friendTableView.backgroundColor = UIColor(red: 1.0, green: 0, blue: 1.0, alpha: 0.2)
    
        // API接続先
        let urlStr = "http://localhost:8080/getFamilyList/\(userId)"
    
        if let url = URL(string: urlStr) {
            let req = NSMutableURLRequest(url: url)
            req.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: req as URLRequest, completionHandler: { (data, resp, err) in
            // 受け取ったdataをJSONパース、エラーならcatchへジャンプ
            do {
                // dataをJSONパースし、変数"getJson"に格納
                getJson = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                //print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as Any)
                self.friendList = getJson["friendlist"] as! NSArray
                //タイトルを取得。
                let item = self.friendList[0]
                if let dict = item as? NSDictionary {
                    self.titleName  = dict["group_name"] as? String ?? "グループ"
                }
    
                DispatchQueue.main.async{
                    //テーブルのデータ再ロード。
//                    self.friendTableView.delegate   = self
//                    self.friendTableView.dataSource = self
//                    self.friendTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "MyCell")
//                    self.view.addSubview(self.friendTableView)
                    self.friendTableView.reloadData()
                    //タイトルを動的表示。
                    self.naviBar.items![0].title = self.titleName
                }
            } catch {
                print ("json error")
                return
            }
        })
        task.resume()
        }
    }
    
    /// セルの個数を指定するデリゲートメソッド（必須）
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList.count
    }
    
    /// セルに値を設定するデータソースメソッド（必須）
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // セルを取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell") as! CustomTableViewCell
        
        // セルに値を設定
        let item = friendList[indexPath.row]
        if let dict = item as? NSDictionary {
            cell.friendNameText.text = dict["name"] as? String
            cell.friendLogText.text = dict["id"] as? String
            cell.friendImageView.image = UIImage(named: imageNames[indexPath.row])
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セルの選択解除
        tableView.deselectRow(at: indexPath, animated: true)

        //値を渡す。
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let item = friendList[indexPath.row]
        if let dict = item as? NSDictionary {
            appDelegate.frinedId = dict["id"] as? String
            appDelegate.frinedName = dict["name"] as? String
        }
        //ここに遷移処理を書く
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "TalkViewController") as! TalkViewController
        self.present(nextView, animated: true, completion: nil)
    }
    
    @IBAction func TalkClearButton(_ sender: Any) {
        //データ保存。
        let userDefaults = UserDefaults.standard
        
        var friendId = "012-345-678"
        var talkList2 = [["123-456-789","012-345-678","今、どこ?"],["012-345-678","123-456-789","なんで?"]]
        userDefaults.set(talkList2, forKey: "TALK\(friendId)")
        userDefaults.synchronize()
        
        friendId = "890-123-456"
        talkList2 = [["123-456-789","890-123-456","今、どこ?"],["890-123-456","123-456-789","今、学校"]]
        userDefaults.set(talkList2, forKey: "TALK\(friendId)")
        userDefaults.synchronize()
        
        friendId = "901-234-567"
        talkList2 = [["123-456-789","901-234-567","今、どこ?"],["901-234-567","123-456-789","今、駅やで"]]
        userDefaults.set(talkList2, forKey: "TALK\(friendId)")
        userDefaults.synchronize()
    }
    
    
}
