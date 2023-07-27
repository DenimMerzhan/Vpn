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
import FirebaseFirestore
import StoreKit

class HomeViewController: UIViewController {
    
    private let defaults = UserDefaults.standard
    private var accessUser = false
    private let db = Firestore.firestore()
    
    var phoneNumber = String()
    var country = Country(name: User.shared.selectedCountry)
    
    private var pressedVPNButton: Bool = false
    private var amountOfDay: String = ""
    private var additionalText = ""
    
    
    @IBOutlet weak var currentCountryVpn: UILabel!
    @IBOutlet weak var currentStatusVpn: UILabel!
    @IBOutlet weak var buttonVPN: UIButton!
    @IBOutlet weak var numberOfDayFreeVersion: UILabel!
    @IBOutlet weak var additionallabel: UILabel!
    
    var currentUser: User? { /// Основная переменная для остлеживания статуса пользователя
        
        didSet {
                
                if currentUser!.subscriptionStatus { /// Если у пользователя активна подписка то открываем доступ
                    accessUser = true
                }
                
                else if currentUser!.freeUser == true { /// Если у пользователя бесплатный контент
                    
                    let differencer = NSDate().timeIntervalSince1970 - currentUser!.dataFirstLaunch
            
                    if differencer > 604800 {  /// Если разница составляет больше 7 денй, у меня в секундах, то закрываем доступ
                        accessUser = false
                        amountOfDay = "Доступ истек"
                        additionalText = ""
                    }else {
                        accessUser = true
                        amountOfDay(second: differencer) /// Преобразуем секунды в дни
                    }
                    
                }else if currentUser!.subscriptionStatus == false { /// Если подписка закончилась
                    accessUser = false
                }
        }
    }

    
    
    
    
//MARK: - Will Appear
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.navigationBar.isHidden = true
        
        if currentUser!.freeUser { /// Если пользователь с бесплатной версией загружаем дату окончания промо периода
            loadData()
        }else { /// Если нет закгружаем квитанцию
            receiptValidation()
        }
        
    }
    
   
    
    
//MARK: - ViewDidLoad
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        switch User.shared.subscriptionStatus {
        case .valid(expirationDate: let expirationDate):
            let rusDate = Formatter.formatToRusDate.string(from: expirationDate)
            additionallabel.text  = "Премиум Активен до \(rusDate)"
        case .ended:
            numberOfDayFreeVersion.text = ""
            additionallabel.text  = "Срок премиум аккаунта истек"
        case .notBuy:
            break
        }
        
        switch User.shared.freeUserStatus {
        case .valid(expirationDate: _):
            numberOfDayFreeVersion.text = User.shared.amountOfDayEndTrialPeriod()
            additionallabel.text = "До истечения бесплатного пользования"
        case .endend:
            numberOfDayFreeVersion.text = "Срок истек"
            additionallabel.isHidden  = true
        case .notActivated:
            break
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeStatus), name: NSNotification.Name.NEVPNStatusDidChange, object: nil) /// Добавляем наблюдателя за впн соединением, в данном случае наш класс VC
        
        currentStatusVpn.text = "VPN отключен"
        
    }
    
    @IBAction func preferencesPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "vpnToPreferences", sender: self)
    }
    
    @IBAction func changeCountryPresed(_ sender: UIButton) {
        performSegue(withIdentifier: "vpnToChangeCountry", sender: self)
    }
    
    
    
    
    
    
    
    //MARK: - Кнопка подключения нажата
    
    
    @IBAction func vpnConnectPressed(_ sender: UIButton) {
        pressedVPNButton = !pressedVPNButton
        
        if User.shared.acesstToVpn { /// Если доступ есть то разрешаем подключение
            
            if pressedVPNButton {

                if let country = self.country  { /// Если в UserDefaults что то есть
                    
                    let credentials = AVVPNCredentials.IKEv2(server: country["serverIP"] as! String, username: country["userName"] as! String, password: country["password"] as! String, remoteId:country["serverIP"] as! String, localId: country["serverIP"] as! String)
                    
                    AVVPNService.shared.connect(credentials: credentials) { error in /// Производим подключение к выбранной стране
                        if error != nil {
                            self.currentStatusVpn.text = "Подключение не удалось \(error!)"
                            print("Ошибка подключения: \(error!)")
                        }
                    }
                }else {
                        createAlert(text: "Выберете страну подключения")
                    }
            
            }else { /// Если кнопка была нажатва второй раз то отключаемся от ВПН
                AVVPNService.shared.disconnect()
            }
            
        }else { /// Если нету доступа уведомляем пользователя
            
            switch User.shared.subscriptionStatus {
            case .ended: createAlert(text: "Ваш срок премиум аккаунта истек. Вы можете его продлить в разделе настроек")
            default:break
            }
            
            switch User.shared.freeUserStatus {
            case.endend:createAlert(text: "Ваш срок бесплатного пользования истек. Вы можете купить премиум аккаунт для его продления")
            default:break
            }
        }
    }
    
}



//MARK: - Отслеживание ВПН соединения


extension HomeViewController {
    
    @objc func didChangeStatus(_ notification: Notification) { /// Отслеживаем статус впн
        
        if let connection = notification.object as? NEVPNConnection {
            
            if connection.status == .connected {
                currentStatusVpn.text = "Подключение выполнено!"
                
                if let country = defaults.dictionary(forKey: "vpnData")  { /// Если в UserDefaults что то есть то оброжаем текущую страну
                    currentCountryVpn.text = "Текущая страна: \(country["name"] as! String)"
                }else {
                    currentCountryVpn.text = "Текущая страна: Россия"
                }
                
                buttonVPN.setImage(UIImage(named: "VPNConnected"), for: [])
                
            }
            
            else if connection.status == .disconnected {
                
                currentStatusVpn.text = "VPN отключен"
                currentCountryVpn.text = ""
                buttonVPN.setImage(UIImage(named: "VpnDIsconnected"), for: [])
            }
            
            else if connection.status == .connecting {
                currentStatusVpn.numberOfLines = 0
                currentStatusVpn.text = "Идет подключение к серверам..."
            }
            
        }
        
    }
}

extension HomeViewController {
    
    func createAlert(text:String){ /// Функция для создания уведомлений
        
        let alert = UIAlertController(title: "Предупреждение!", message:text, preferredStyle: .alert)
        present(alert, animated: true)
        alert.addAction(UIAlertAction(title: "ок", style: .default))
        
    }
}




    
    
