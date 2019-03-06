//
//  LoginViewController.swift
//  GpsStalker
//
//  Created by 高田穂乃花 on 2019/02/03.
//  Copyright © 2019 stalker. All rights reserved.
//

import UIKit

class userItem: Codable {
    var result: String = ""
    var id: String = ""
    var name: String = ""
    var tel: String = ""
    
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorTextField: UILabel!
    
    private var userMail: String = ""
    private var userPass: String = ""
    private var userId: String = ""
    private var userName: String = ""
    private var userTel: String = ""
    private var groupId: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func tapLoginButton(_ sender: Any) {
        
        userMail = mailTextField.text!
        userPass = passwordTextField.text!
        
        if userMail == "" || userPass == "" {
            errorTextField.text = "メールアドレスとパスワードを両方とも入力して下さい。"
        } else {
            
            getUserData()
            
        }
    }
    
    func  getUserData() {
        
        // 取得したJSONを格納する変数を定義
        var getJson: NSDictionary!
        
        //「/」はまだダメ!!
        let keyword_encode = userMail.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let keyword_encode2 = userPass.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        // API接続先
        let urlStr = "http://localhost:8080/getLoginUserData/\(keyword_encode!)/\(keyword_encode2!)"
        
        print(urlStr)
        
        if let url = URL(string: urlStr) {
            let req = NSMutableURLRequest(url: url)
            req.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: req as URLRequest, completionHandler: { (data, resp, err) in
                // 受け取ったdataをJSONパース、エラーならcatchへジャンプ
                do {
                    // dataをJSONパースし、変数"getJson"に格納
                    getJson = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as Any)
                    var userData: NSArray = []
                    userData = getJson["loginuserdata"] as! NSArray
                    //タイトルを取得。
                    let item = userData[0]
                    if let dict = item as? NSDictionary {
                        self.userId  = dict["id"] as? String ?? ""
                        self.userName  = dict["name"] as? String ?? ""
                        self.userTel  = dict["tel"] as? String ?? ""
                        self.groupId = dict["groupid"] as? String ?? ""
                        
                        //データ保存。
                        let userDefaults = UserDefaults.standard
                        // Keyを指定して保存
                        userDefaults.set(self.userId, forKey: "USERID")
                        userDefaults.set(self.userName, forKey: "USERNAME")
                        userDefaults.set(self.userMail, forKey: "USERMAIL")
                        userDefaults.set(self.userTel, forKey: "USERTEL")
                        userDefaults.set(self.groupId, forKey: "GROUPID")
                        print(self.groupId)
                        userDefaults.synchronize()
                        
                    }
                    
                    DispatchQueue.main.async{
                        //画面遷移処理。
                        let storyboard: UIStoryboard = self.storyboard!
                        let nextView = storyboard.instantiateViewController(withIdentifier: "PageViewController") as! PageViewController
                        self.present(nextView, animated: true, completion: nil)
                    }
                } catch {
                    print ("json error")
                    return
                }
            })
            task.resume()
        }
        
    }
    
    @IBAction func pushUser01Button(_ sender: Any) {
        mailTextField.text = "hal.osaka@gmail.com"
        passwordTextField.text = "971001"
    }
    
    @IBAction func pushUser02Button(_ sender: Any) {
        mailTextField.text = "yumi0121@gmail.com"
        passwordTextField.text = "mam"
    }
    
    
}
