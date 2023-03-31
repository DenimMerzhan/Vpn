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

class ViewController: UIViewController, AVVPNServiceDelegate {

    
    @IBOutlet weak var currentStatusVpn: UILabel!
    @IBOutlet weak var buttonVPN: UIButton!
    
    
    var pressedVPNButton: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        AVVPNService.shared.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeStatus), name: NSNotification.Name.NEVPNStatusDidChange, object: nil) /// Добавляем наблюдателя, в данном случае наш класс VC
        
        currentStatusVpn.text = "VPN отключен"
        
    }
    
    
    
    
    @IBAction func vpnConnectPressed(_ sender: UIButton) {
        pressedVPNButton = !pressedVPNButton
        
        if pressedVPNButton {
            
            let credentials = AVVPNCredentials.IPSec(server: "62.84.98.66", username: "vpnuser", password: "FEdJF89frXxLr9kE", shared: "fbfe64e2359a248448a771c044758a39")
            
            AVVPNService.shared.connect(credentials: credentials) { error in
                if error != nil {
                    self.currentStatusVpn.text = "Подключение не удалось"
                    print("Ошибка подключения: \(error!)")
                }
            }

        }else {
            AVVPNService.shared.disconnect()
        }

    }
    
    
    @IBAction func changeCountryPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "goToChangeCountry", sender: self)
    }
    
    }


/// Отслеживание ВПН соединения



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

    
    
