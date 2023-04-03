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

class ViewController: UIViewController, transtitonDataServer {
    
    let defaults = UserDefaults.standard
    func transitionCountry(country: Country) {
        currentCountry = country
        defaults.set(currentCountry?.name, forKey: "CurrentCountry")
    }

    @IBOutlet weak var currentCountryVpn: UILabel!
    @IBOutlet weak var currentStatusVpn: UILabel!
    @IBOutlet weak var buttonVPN: UIButton!
    
    var currentCountry: Country?
    var pressedVPNButton: Bool = false
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        
        if let currentCountryName = defaults.string(forKey: "CurrentCountry") {
            currentCountryVpn.text = "Текущая страна: \(currentCountryName)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeStatus), name: NSNotification.Name.NEVPNStatusDidChange, object: nil) /// Добавляем наблюдателя, в данном случае наш класс VC
        
        currentStatusVpn.text = "VPN отключен"
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? ChangeCountryController else { return }
        destination.delegate = self
    }

    
    
    
    
    
//MARK: - Кнопка подключения нажата
    
    
    @IBAction func vpnConnectPressed(_ sender: UIButton) {
        pressedVPNButton = !pressedVPNButton
        
        if pressedVPNButton {
            
            var credentials = AVVPNCredentials.IPSec(server: "91.142.73.170", username: "vpnuser", password: "fj1v5R3qaDPavFgj", shared: "14e70a6b1363b6442e02036719ee9703")
            
            if let country = currentCountry { /// Если задана новая страна в настройках "Выбрать страну" то мы подключаемся к новой стране
                print(country.serverIP)
                
                credentials = AVVPNCredentials.IPSec(server: country.serverIP, username: country.userName, password: country.password, shared: country.sharedKey)
                
                
            } else { /// Иначе подключаемся по умолчанию к России
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
            
        }
    
    
    
    @IBAction func changeCountryPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "goToChangeCountry", sender: self)
    }
    
    
    
    
    
    
    
//MARK: - Кнопка выхода нажата
    
    
    @IBAction func logOutPressed(_ sender: UIButton) {
        
        do {
          try Auth.auth().signOut() /// Пытаемся выйти из учетной записи
            navigationController?.popToRootViewController(animated: true) /// Отправляем пользователя на корневой/ главный экран
        } catch let signOutError as NSError {  /// Если не получилось выйти из учетной записи в Firestore
          print("Error signing out: %@", signOutError)
        }
    }
    
    }






//MARK: - Отслеживание ВПН соединения



extension ViewController {
    
    @objc func didChangeStatus(_ notification: Notification) {
        
        if let connection = notification.object as? NEVPNConnection {
            
            if connection.status == .connected {
                currentStatusVpn.text = "Подключение выполнено!"
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
                print("Ошибка подключения: Связанная конфигурация VPN не существует в настройках расширения сети или не включена")
            }
        }
        
    }
}

    
    
