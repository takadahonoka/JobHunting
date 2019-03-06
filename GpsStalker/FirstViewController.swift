//
//  FirstViewController.swift
//  GpsStalker
//
//  Created by 高田穂乃花 on 2019/01/25.
//  Copyright © 2019 stalker. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class FirstViewController: UIViewController, UIScrollViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var userMapView: MKMapView!
    
    //CLLocationManagerの入れ物を用意
    var locationManager:CLLocationManager!
    var userLocation: CLLocationCoordinate2D!
    var destLocation: CLLocationCoordinate2D!
    //ユーザーID。
    var userId: String = ""
    var groupId: String = ""
    //現在地の緯度経度。
    var latitude: Double = 0
    var longitude: Double = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //データ保存。
        let userDefaults = UserDefaults.standard
        userId = userDefaults.string(forKey: "USERID")!
        groupId = userDefaults.string(forKey: "GROUPID")!
        
        setupLocationManager()
        timerUpdate2()
        
        //Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(FirstViewController.timerUpdate), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(FirstViewController.timerUpdate2), userInfo: nil, repeats: true)
    }
    
    //現在地の緯度経度を取得。
    func setupLocationManager() {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }
        locationManager.requestWhenInUseAuthorization()
        
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            locationManager.delegate = self
            locationManager.distanceFilter = 10
            locationManager.startUpdatingLocation()
        }
    }
    
    //2秒毎に動作する(INSERTする)。
    @objc func timerUpdate() {
        setupLocationManager()
        
        // 取得したJSONを格納する変数を定義。
        var getJson: NSDictionary!
        
        // API接続先
        let sampleId: String = "123-456-789"
        let urlStr = "http://localhost:8080/insertMapData/\(sampleId)/\(self.latitude)/\(self.longitude)"
        
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
                        
                        if (result == "true") {
                            //self.talkTextField.text = ""
                            print("位置情報:INSERT成功")
                        } else {
                            //self.talkTextField.text = "失敗"
                            print("位置情報:INSERT失敗")
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
    
    //5秒毎に動作する(情報を取得する)。
    @objc func timerUpdate2() {

        // 取得したJSONを格納する変数を定義。
        var getJson: NSDictionary!
        
        print("グループID:\(groupId)")
        
        // API接続先
        let urlStr = "http://localhost:8080/getLocationList/\(groupId)"
        
        if let url = URL(string: urlStr) {
            let req = NSMutableURLRequest(url: url)
            req.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: req as URLRequest, completionHandler: { (data, resp, err) in
                // 受け取ったdataをJSONパース、エラーならcatchへジャンプ
                do {
                    // dataをJSONパースし、変数"getJson"に格納
                    getJson = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as Any)
                    var locationData: NSArray = []
                    locationData = getJson["mapdata"] as! NSArray
                    //タイトルを取得。
//                    let item = locationData[0]
//                    if let dict = item as? NSDictionary {
//                        self.titleName  = dict["group_name"] as? String ?? "グループ"
//                    }
                    print(locationData)
                    
                    DispatchQueue.main.async{
                        
                        self.locationManager.delegate = self
                        self.userMapView.delegate = self
                        
                        for i in 0..<locationData.count {
                            
                            if (i+1) != locationData.count {
                            
                                let item = locationData[i]
                                if let dict = item as? NSDictionary {
                                    
                                    let getLatitude: String = dict["latitude"] as? String ?? ""
                                    let getLongitude: String = dict["longitude"] as? String ?? ""
                                    
                                    print(Double(getLatitude)!)
                                
                                    // 場所01の座標を取得
                                    self.userLocation = CLLocationCoordinate2DMake(Double(getLatitude)!, Double(getLongitude)!)
                                    let annotation = MKPointAnnotation()
                                    annotation.coordinate = CLLocationCoordinate2DMake(Double(getLatitude)!, Double(getLongitude)!)
                                    self.userMapView.addAnnotation(annotation) // 目的地にピンを立てる
                                }
                                
                                let item2 = locationData[i+1]
                                if let dict = item2 as? NSDictionary {
                                    
                                    let getLatitude: String = dict["latitude"] as? String ?? ""
                                    let getLongitude: String = dict["longitude"] as? String ?? ""
                                    
                                    // 場所02の座標を取得
                                    self.destLocation = CLLocationCoordinate2DMake(Double(getLatitude)!, Double(getLongitude)!)
                                    let userLocAnnotation = MKPointAnnotation()
                                    userLocAnnotation.coordinate = CLLocationCoordinate2DMake(Double(getLatitude)!, Double(getLongitude)!)
                                    self.userMapView.addAnnotation(userLocAnnotation) // 目的地にピンを立てる
                                }
                                // 現在地から目的地家の経路を検索
                                self.getRoute()
                            }
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
    
    //現在地取得成功時。
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.first
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        
        self.latitude = latitude!
        self.longitude = longitude!
        
        print("latitude: \(latitude!)\nlongitude: \(longitude!)")
    }
    
    //現在地取得失敗時。
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("現在地取得失敗!!")
    }
}

//Map関連。
extension FirstViewController {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            // 位置情報の取得開始
            self.locationManager.startUpdatingLocation()
            break
        case .notDetermined:
            print("ユーザーはこのアプリケーションに関してまだ選択を行っていません")
            self.locationManager.requestWhenInUseAuthorization() // 起動中のみの取得許可を求める
            // 許可を求めるコードを記述する（後述）
            break
        case .denied:
            print("ローケーションサービスの設定が「無効」になっています (ユーザーによって、明示的に拒否されています）")
            // 「設定 > プライバシー > 位置情報サービス で、位置情報サービスの利用を許可して下さい」を表示する
            break
        case .restricted:
            print("このアプリケーションは位置情報サービスを使用できません(ユーザによって拒否されたわけではありません)")
            // 「このアプリは、位置情報を取得できないために、正常に動作できません」を表示する
            break
        case .authorizedAlways:
            print("常時、位置情報の取得が許可されています。")
            // 位置情報取得の開始処理
            break
        }
    }
    
    //経路を求める。
    func getRoute()
    {
        // 現在地と目的地のMKPlacemarkを生成
        let fromPlacemark = MKPlacemark(coordinate:userLocation, addressDictionary:nil)
        let toPlacemark   = MKPlacemark(coordinate:destLocation, addressDictionary:nil)
        
        // MKPlacemark から MKMapItem を生成
        let fromItem = MKMapItem(placemark:fromPlacemark)
        let toItem   = MKMapItem(placemark:toPlacemark)
        
        // MKMapItem をセットして MKDirectionsRequest を生成
        let request = MKDirections.Request()
        
        request.source = fromItem
        request.destination = toItem
        request.requestsAlternateRoutes = false // 単独の経路を検索
        request.transportType = MKDirectionsTransportType.any
        
        let directions = MKDirections(request: request)
        directions.calculate(completionHandler: {(response, error) -> Void in
            _ = response!.routes.count
            if (error != nil || response!.routes.isEmpty) {
                return
            }
            let route: MKRoute = response!.routes[0] as MKRoute
            // 経路を描画
            self.userMapView.addOverlay(route.polyline)
            // 現在地とz目的地を含む表示範囲を設定する
            self.showUserAndDestinationOnMap()
        })
    }
    
    // 地図の表示範囲を計算
    func showUserAndDestinationOnMap()
    {
        // 現在地と目的地を含む矩形を計算
        let maxLat:Double = fmax(userLocation.latitude,  destLocation.latitude)
        let maxLon:Double = fmax(userLocation.longitude, destLocation.longitude)
        let minLat:Double = fmin(userLocation.latitude,  destLocation.latitude)
        let minLon:Double = fmin(userLocation.longitude, destLocation.longitude)
        
        print("userLocationの:\(userLocation.latitude)、\(userLocation.longitude)")
        print("destLocationの:\(destLocation.latitude)、\(destLocation.longitude)")
        
        // 地図表示するときの緯度、経度の幅を計算
        let mapMargin:Double = 1.5;  // 経路が入る幅(1.0)＋余白(0.5)
        let leastCoordSpan:Double = 0.005;    // 拡大表示したときの最大値
        let span_x:Double = fmax(leastCoordSpan, fabs(maxLat - minLat) * mapMargin);
        let span_y:Double = fmax(leastCoordSpan, fabs(maxLon - minLon) * mapMargin);
        
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: span_x, longitudeDelta: span_y);
        
        // 現在地を目的地の中心を計算
        let center:CLLocationCoordinate2D = CLLocationCoordinate2DMake((maxLat + minLat) / 2, (maxLon + minLon) / 2);
        let region:MKCoordinateRegion = MKCoordinateRegion(center: center, span: span);
        
        userMapView.setCenter(userMapView.userLocation.coordinate, animated: true)
        userMapView.setRegion(userMapView.regionThatFits(region), animated:true);
    }
    
    // 経路を描画するときの色や線の太さを指定
    func mapView(_ mapView: MKMapView!, rendererFor overlay: MKOverlay!) -> MKOverlayRenderer! {
        print("経路を描画するときの色や線の太さを指定")
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.magenta
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        return nil
    }
}
