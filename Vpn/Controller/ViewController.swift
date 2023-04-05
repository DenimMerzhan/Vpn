//
//  ViewController.swift
//  Vpn
//
//  Created by Деним Мержан on 28.03.23.
//

import UIKit
import ChameleonFramework
import AVVPNService
import NetworkExtension
import FirebaseAuth

class ViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    var accessUser = true
    var pressedVPNButton: Bool = false
    var amountOfDay: String = ""
    
    var currentUser: Users? {
        didSet {
            
            let differencer = NSDate().timeIntervalSince1970 - currentUser!.dataFirstLaunch
            if differencer > 604800 {  /// Если разница составляет больше 7 денй, у меня в секундах, то закрываем доступ
                accessUser = false
            }else {
                amountOfDat(second: differencer)
            }
                        
        }
    }
    
    
    @IBOutlet weak var currentCountryVpn: UILabel!
    @IBOutlet weak var currentStatusVpn: UILabel!
    @IBOutlet weak var buttonVPN: UIButton!
    @IBOutlet weak var numberOfDayFreeVersion: UILabel!
    
    @IBOutlet weak var additionallabel: UILabel!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentCountryVpn.text = ""
        
        if accessUser {
            numberOfDayFreeVersion.text = amountOfDay
        }else {
            numberOfDayFreeVersion.text = "Срок истек"
            additionallabel.isHidden  = true
        }
        
        if currentUser!.firstLaunch {
            creatAlert(text: "Ваш бесплатный доступ состовляет 7 дней. Приятного пользования!")
        }

        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeStatus), name: NSNotification.Name.NEVPNStatusDidChange, object: nil) /// Добавляем наблюдателя, в данном случае наш класс VC
        
        currentStatusVpn.text = "VPN отключен"
        
    }
    
    
    
    
    
  
    
    
    
    
    //MARK: - Кнопка подключения нажата
    
    
    @IBAction func vpnConnectPressed(_ sender: UIButton) {
        pressedVPNButton = !pressedVPNButton
        
        if accessUser {
            
            if pressedVPNButton {
                
                var credentials = AVVPNCredentials.IPSec(server: "91.142.73.170", username: "vpnuser", password: "fj1v5R3qaDPavFgj", shared: "14e70a6b1363b6442e02036719ee9703")
                
                
                if let country = defaults.dictionary(forKey: "vpnData")  { /// Если в UserDefaults что то есть
                    
                    credentials = AVVPNCredentials.IPSec(server: country["serverIP"] as! String , username: country["userName"] as! String, password: country["password"] as! String, shared: country["sharedKey"] as! String)
                    
                }else { /// Иначе подключаемся по умолчанию к России
                    currentCountryVpn.text = "Текущая страна: Россия"
                }
                
                
                AVVPNService.shared.connect(credentials: credentials) { error in /// Производим подключение к выбранной стране
                    if error != nil {
                        self.currentStatusVpn.text = "Подключение не удалось"
                        print("Ошибка подключения: \(error!)")
                    }
                    
                }
                
            }else { /// Если кнопка была нажатва второй раз то отключаемся от ВПН
                AVVPNService.shared.disconnect()
            }
            
        }else {
           creatAlert(text: "Ваш срок бесплатного пользования истек. Вы можете купить премиум аккаунт для его продления")
        }
        
        
    }
    
    
    
    
//MARK: - Смена страны
    
    @IBAction func changeCountryPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "goToChangeCountry", sender: self)
    }
    
    
}





















//MARK: - Отслеживание ВПН соединения


extension ViewController {
    
    @objc func didChangeStatus(_ notification: Notification) {
        
        if let connection = notification.object as? NEVPNConnection {
            
            if connection.status == .connected {
                currentStatusVpn.text = "Подключение выполнено!"
                
                if let country = defaults.dictionary(forKey: "vpnData")  { /// Если в UserDefaults что то есть
                    currentCountryVpn.text = "Текущая страна: \(country["name"] as! String)"
                 }
                
                
                
                buttonVPN.setImage(UIImage(named: "VPNConnected"), for: [])
                
            }
            
            else if connection.status == .disconnected {
                currentStatusVpn.text = "VPN отключен"
                buttonVPN.setImage(UIImage(named: "VpnDIsconnected"), for: [])
            }
            
            else if connection.status == .connecting {
                currentStatusVpn.text = "Идет подключение к серверам..."
            }
            
            else {
                creatAlert(text: "Ошибка подключения: Связанная конфигурация VPN не существует в настройках расширения сети или не включена")
            }
        }
        
    }
    
    func loadData(){
        let data = LoadFireBaseData().loadData()
        print(data)
        
    }
}





//MARK: - Создаем уведомление и отоброжаем количество оставшихся дней

extension ViewController {
    
    
    func creatAlert(text: String){
        
        let alert = UIAlertController(title: "Предупреждение!", message: text, preferredStyle: .alert)
        present(alert, animated: true)
        
        alert.addAction(UIAlertAction(title: "ок", style: .default))
        
        
    }
    
    
    
    func amountOfDat(second: TimeInterval){
        let diff = 7 - Int(second / 86400)
        if diff > 4 || diff == 0 {
            amountOfDay = "\(String(diff)) дней"
        }else if diff > 1 {
            amountOfDay = "\(String(diff)) дня"
        }else {
            amountOfDay = "\(String(diff)) день"
        }
        
        
        
    }
}


    
    
