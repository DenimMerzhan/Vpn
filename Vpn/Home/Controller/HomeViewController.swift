//
//  ViewController.swift
//  Vpn
//
//  Created by Деним Мержан on 28.03.23.
//

import UIKit
import AVVPNService
import NetworkExtension
import FirebaseAuth
import FirebaseFirestore
import StoreKit

class HomeViewController: UIViewController {
    
    private var pressedVPNButton: Bool = false
    private let homeModel = HomeModel()
    private let homeNetworkService = HomeNetworkService()
    
    var country: Server?
    
    @IBOutlet weak var currentCountryVpn: UILabel!
    @IBOutlet weak var currentStatusVpn: UILabel!
    @IBOutlet weak var buttonVpn: UIImageView!
    @IBOutlet weak var numberOfDayFreeVersion: UILabel!
    @IBOutlet weak var additionallabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeStatus), name: NSNotification.Name.NEVPNStatusDidChange, object: nil) /// Добавляем наблюдателя за впн соединением
        
        homeNetworkService.getFreeServerAcount(serverName: "Амстердам")
        currentStatusVpn.text = "VPN отключен"
        buttonVpn.isUserInteractionEnabled = true
        checkUserStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.navigationBar.isHidden = true
    }
    
    
    @IBAction func preferencesPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "homeVCToPreferences", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let menuVC = segue.destination as? MenuViewController {
            menuVC.delegate = self
        }else if let changeCountryVC = segue.destination as? ChangeCountryController {
            changeCountryVC.delegate = self
        }
    }
    
    //MARK: - Кнопка подключения нажата
    
    @IBAction func vpnButtonPressed(_ sender: UITapGestureRecognizer) {
        
        pressedVPNButton = !pressedVPNButton
        
        if CurrentUser.shared.acesstToVpn { /// Если доступ есть то разрешаем подключение
            
            if pressedVPNButton {
                
                if let country = self.country  {
                    
                    let credentials = AVVPNCredentials.IKEv2(server: country.serverIP, username: country.userName, password: country.password, remoteId:country.serverIP, localId: country.serverIP)
                    
                    AVVPNService.shared.connect(credentials: credentials) { error in /// Производим подключение к выбранной стране
                        if error != nil {
                            self.currentStatusVpn.text = "Подключение не удалось \(error!)"
                            print("Ошибка подключения: \(error!)")
                        }
                    }
                }else {
                    let alert = homeModel.createAlert(text: "Выберете страну подключения")
                    self.present(alert, animated: true)
                    }
            
            }else { /// Если кнопка была нажатва второй раз то отключаемся от ВПН
                AVVPNService.shared.disconnect()
            }
            
        }else { /// Если нету доступа уведомляем пользователя
            
            switch CurrentUser.shared.subscriptionStatus {
            case .ended:
                let alert = homeModel.createAlert(text: "Ваш срок подписки истек. Вы можете его продлить в разделе настроек")
                self.present(alert, animated: true)
            default:break
            }
            
            switch CurrentUser.shared.freeUserStatus {
            case.endend:
                let alert = homeModel.createAlert(text: "Ваш срок бесплатного пользования истек. Вы можете активировать платную подписку для доступа к услугам")
                self.present(alert, animated: true)
            default:break
            }
        }
    }
}

//MARK: -  Проверка статуса пользователя

extension HomeViewController: MenuControllerDelegate {
    
    func userBuyPremium() {
        checkUserStatus()
    }
    
    func checkUserStatus(){
        
        switch CurrentUser.shared.subscriptionStatus {
        case .valid(expirationDate: let expirationDate):
            let rusDate = Formatter.formatToRusDate.string(from: expirationDate)
            additionallabel.text  = "Подписка активна до \(rusDate)"
            numberOfDayFreeVersion.text = ""
        case .ended:
            numberOfDayFreeVersion.text = ""
            additionallabel.text  = "Срок подписки истек"
        case .notBuy:
            break
        }
        
        switch CurrentUser.shared.freeUserStatus {
        case .valid(expirationDate: let expirationDate):
            numberOfDayFreeVersion.text = homeModel.amountOfDayEndTrialPeriod(expirationDate: expirationDate)
            additionallabel.text = "До истечения бесплатного пользования"
        case .endend:
            numberOfDayFreeVersion.text = ""
            additionallabel.text = "Срок бесплатного пользования истек"
        case .blocked:
            break
        }
    }
}


//MARK: - Отслеживание ВПН соединения


extension HomeViewController {
    
    @objc func didChangeStatus(_ notification: Notification) { /// Отслеживаем статус впн
        
        if let connection = notification.object as? NEVPNConnection {
            
            if connection.status == .connected {
                currentStatusVpn.text = "Подключение выполнено!"
                
                if let nameCountry = country?.name {
                    currentStatusVpn.text = "Текущая страна: \(nameCountry)"
                }
                buttonVpn.image = UIImage(named: "VPNConnected")
                
            }
            
            else if connection.status == .disconnected {
                currentStatusVpn.text = "VPN отключен"
                currentCountryVpn.text = ""
                buttonVpn.image = UIImage(named: "VpnDIsconnected")
            }
            
            else if connection.status == .connecting {
                currentStatusVpn.numberOfLines = 0
                currentStatusVpn.text = "Идет подключение к серверам..."
            }
            
        }
        
    }
}

//MARK: - ChangeCountryDelegate

extension HomeViewController: ChangeCountryDelegate {
    
    func countryHasBeenChanged(country: Server) {
        self.country = country
    }
}




    
    
