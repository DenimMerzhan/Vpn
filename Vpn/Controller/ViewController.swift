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

class ViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    var accessUser = true
    let db = Firestore.firestore()
    var subscriptionStatus = Bool()
    
    var pressedVPNButton: Bool = false
    var amountOfDay: String = "ff"
    var currentDevice = String()
    
    
    
    @IBOutlet weak var currentCountryVpn: UILabel!
    @IBOutlet weak var currentStatusVpn: UILabel!
    @IBOutlet weak var buttonVPN: UIButton!
    @IBOutlet weak var numberOfDayFreeVersion: UILabel!
    @IBOutlet weak var additionallabel: UILabel!
    
    var currentUser: Users? {
        
        didSet {
            
            if currentUser != nil {
                let differencer = NSDate().timeIntervalSince1970 - currentUser!.dataFirstLaunch
                if differencer > 604800 {  /// Если разница составляет больше 7 денй, у меня в секундах, то закрываем доступ
                    accessUser = false
                    accesUserFalse()
                }else {
                    amountOfDay(second: differencer) /// Преобразуем секунды в дни
                }
                
            }
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        
        currentDevice = defaults.string(forKey: "CurrentDevice") ?? "Нет данных"
        loadData()
        navigationController?.navigationBar.isHidden = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentCountryVpn.text = ""
    
        
        if let current = currentUser?.firstLaunch {
            if current {
                creatAlert(text: "Ваш бесплатный доступ состовляет 7 дней. Приятного пользования!")
            }
                
        }

        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeStatus), name: NSNotification.Name.NEVPNStatusDidChange, object: nil) /// Добавляем наблюдателя, в данном случае наш класс VC
        
        currentStatusVpn.text = "VPN отключен"
        
    }
    
    
  
    
    
    
    
    //MARK: - Кнопка подключения нажата
    
    
    @IBAction func vpnConnectPressed(_ sender: UIButton) {
        pressedVPNButton = !pressedVPNButton
        
        if accessUser { /// Если доступ есть то разрешаем подключение
            
            if pressedVPNButton {
                
                var credentials = AVVPNCredentials.IPSec(server: "91.142.73.170", username: "vpnuser", password: "fj1v5R3qaDPavFgj", shared: "14e70a6b1363b6442e02036719ee9703")
                
                
                if let country = defaults.dictionary(forKey: "vpnData")  { /// Если в UserDefaults что то есть
                    
                    credentials = AVVPNCredentials.IPSec(server: country["serverIP"] as! String , username: country["userName"] as! String, password: country["password"] as! String, shared: country["sharedKey"] as! String)
                    
                }else { /// Иначе подключаемся по умолчанию к России
                    currentCountryVpn.text = "Текущая страна: Россия"
                }
                
                
                AVVPNService.shared.connect(credentials: credentials) { error in /// Производим подключение к выбранной стране
                    if error != nil {
                        self.currentStatusVpn.text = "Подключение не удалось \(error!)"
                        print("Ошибка подключения: \(error!)")
                    }
                    
                }
                
            }else { /// Если кнопка была нажатва второй раз то отключаемся от ВПН
                AVVPNService.shared.disconnect()
            }
            
        }else { /// Если нету то уведомляем пользователя
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
    
    @objc func didChangeStatus(_ notification: Notification) { /// Отслеживаем статус впн
        
        if let connection = notification.object as? NEVPNConnection {
            
            if connection.status == .connected {
                currentStatusVpn.text = "Подключение выполнено!"
                
                if let country = defaults.dictionary(forKey: "vpnData")  { /// Если в UserDefaults что то есть то оброжаем текущую страну
                    currentCountryVpn.text = "Текущая страна: \(country["name"] as! String)"
                 }
                
                buttonVPN.setImage(UIImage(named: "VPNConnected"), for: [])
                
            }
            
            else if connection.status == .disconnected {
                currentStatusVpn.text = "VPN отключен"
                currentCountryVpn.text = ""
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
    

}





//MARK: - Создаем уведомление и отоброжаем количество оставшихся дней

extension ViewController {
    
    
    func creatAlert(text: String){ /// Функция для создания уведомлений
        
        let alert = UIAlertController(title: "Предупреждение!", message: text, preferredStyle: .alert)
        present(alert, animated: true)
        
        alert.addAction(UIAlertAction(title: "ок", style: .default))
        
        
    }
    
    func accesUserFalse(){ /// Отображаем пользователю, что его доступ истек
        
    }
    
    
    
    func amountOfDay(second: TimeInterval){ /// Подсчитываем сколько дней осталось до конца бесплатного периода
        
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



//MARK: - Загрузка данных о пользователе

extension ViewController {
    
    func loadData() {
        
        db.collection("Users").getDocuments { QuerySnapshot, Error in
            if let err = Error {
                print("Ошибка получения данных - \(err)")
            }
            
            for document in QuerySnapshot!.documents {
                
                if document.documentID == self.currentDevice { /// Если текущий пользователь уже был зарегестрирован
                    
            
                   let date =  document["dataFirstLaunch"] as! TimeInterval /// Преобразуем данные из FireBase
                   let subscription = document["subscription"] as! Bool /// Отображаем сведения о подписке
                   self.currentUser = Users(dataFirstLaunch: date, firstLaunch: false, subscription: subscription)

                    
                    DispatchQueue.main.async { /// Как только посчитано количество дней, мы отоброжаем инфу пользователю
                        
                        if self.accessUser {
                            self.numberOfDayFreeVersion.text = self.amountOfDay
                            self.additionallabel.text = "До истечения бесплатного пользования"
                        }else {
                            self.numberOfDayFreeVersion.text = "Срок истек"
                            self.additionallabel.isHidden  = true
                        }
                        
                    }
                    
                }
            }
        }
    }
}



/// 

extension ViewController {
    
    func receiptValidation(){
        let urlString = "https://sandbox.itunes.apple.com/verifyReceipt" /// Указываем что берем даныне с песочницы
        
        guard let receiptURL = Bundle.main.appStoreReceiptURL, let receiptString = try? Data(contentsOf: receiptURL).base64EncodedString() , let url = URL(string: urlString) else { /// 1 URL-адрес файла для квитанции App Store о пакете.   2  Преобразуем в строку    3 преобразуем наш URL песочницы в URL
                       return
               }
        
        let requestData : [String : Any] = ["receipt-data" : receiptString, /// Создаем словарь
                                                    "password" : "11f70af409dc42dfadee27090ff87b66", /// пароль это секретный ключ
                                                    "exclude-old-transactions" : false] /// Исключать старые транзакции нет
        
        let httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: []) /// Объект, который выполняет преобразование между JSON и эквивалентными объектами Foundation.
        
        
        
        var request = URLRequest(url: url) /// Запрос загрузки URL, который не зависит от протокола или схемы URL.
        request.httpMethod = "POST" /// POST — означает что некоторые данные должны быть помещены на сервер.
        
        
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type") /// Задает значение для поля заголовка. Field Имя поля заголовка для установки. В соответствии с HTTP RFC имена полей заголовков HTTP нечувствительны к регистру.
        
        
        request.httpBody = httpBody /// Данные, отправляемые в виде тела сообщения запроса, например, для HTTP-запроса POST.
        
        URLSession.shared.dataTask(with: request) { data, respose, error in
            
            DispatchQueue.main.async {
                
                if let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] { /// Преобразуем файл Json в словарь
                    
                    
                    let dataArr = jsonData["latest_receipt_info"] as! [[String: Any]]
                    let subscriptionExpirationDate = dataArr[0]["expires_date"] as! String // Берем последний массив и от туда дату окончания подписки
                    let daty = dataArr[0]["expires_date"] as! Date
                    print(daty)
                    if let dateEndSubscription = Formatter.customDate.date(from: subscriptionExpirationDate) { /// Форматиурем нашу строку в дату
                        
                        if Date() > dateEndSubscription {
                            self.subscriptionStatus = false
                        }
                    }

                    
              }
            }
            
        }.resume()
        
    }
    
}

    
    
