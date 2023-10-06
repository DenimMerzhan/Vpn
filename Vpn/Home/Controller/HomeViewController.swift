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

    private var isVpnButtonPressed: Bool = false
    private let homeModel = HomeModel()
    private let homeNetworkService = HomeNetworkService()
    
    var server: Server?
    
    @IBOutlet weak var currentCountryVpn: UILabel!
    @IBOutlet weak var currentStatusVpn: UILabel!
    @IBOutlet weak var buttonVpn: UIImageView!
    @IBOutlet weak var numberOfDayFreeVersion: UILabel!
    @IBOutlet weak var additionallabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeStatus), name: NSNotification.Name.NEVPNStatusDidChange, object: nil) /// Добавляем наблюдателя за впн соединением
        
        homeNetworkService.delegate = self
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
        }
    }
    
    //MARK: - Кнопка подключения нажата
    
    @IBAction func vpnButtonPressed(_ sender: UITapGestureRecognizer) {
        
        isVpnButtonPressed = !isVpnButtonPressed
        
        if CurrentUser.shared.acesstToVpn { /// Если доступ есть то разрешаем подключение
            
            if isVpnButtonPressed {
                connectToVpn()
            }else { /// Если кнопка была нажатва второй раз то отключаемся от ВПН
                AVVPNService.shared.disconnect()
                if let server = CurrentUser.shared.selectedServerName {
                    homeNetworkService.deleteConnectionStatus(serverName: server,userID: CurrentUser.shared.ID)
                }
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

//MARK: - ConnectToVpn

extension HomeViewController: HomeNetworkServiceProtocol {
    
    func connectToVpn(){
        
        if let serverName = CurrentUser.shared.selectedServerName  {
            
            currentStatusVpn.text = "Идет получение данных о сервере..."
            
            homeNetworkService.getServerData(serverName: serverName) { [weak self] server in
                
                self?.server = server
                
                let credentials = AVVPNCredentials.IKEv2(server: server.serverIP, username: server.userName, password: server.password, remoteId:server.remoteID, localId: server.loaclID)
                
                AVVPNService.shared.connect(credentials: credentials) { error in /// Производим подключение к выбранной стране
                    
                    if error != nil {
                        self?.currentStatusVpn.text = "Подключение не удалось \(error!)"
                        print("Ошибка подключения: \(error!)")
                    }
                }
            }
        }else {
            let alert = homeModel.createAlert(text: "Выберете сервер для подключения")
            self.present(alert, animated: true)
        }
        
    }
    
    func loadServerWithError(error: NetworkError) {
        let alert = homeModel.createAlert(text: error.errorDescripiton)
        self.present(alert, animated: true)
        isVpnButtonPressed = !isVpnButtonPressed
        currentStatusVpn.text = "VPN отключен"
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
                
                if let nameCountry = CurrentUser.shared.selectedServerName {
                    currentStatusVpn.text = "Текущий сервер: \(nameCountry)"
                }
                buttonVpn.image = UIImage(named: "VPNConnected")
                
                if let server = server {
                    homeNetworkService.writeConnectionStatus(server: server)
                }
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







