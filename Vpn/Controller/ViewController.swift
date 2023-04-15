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

class ViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    var accessUser = false
    let db = Firestore.firestore()
    
    var noSubscriptionsFound = false
    var freeUser = Bool()
    var phoneNumber = String()
    
    var pressedVPNButton: Bool = false
    var amountOfDay: String = ""
    var additionalText = ""
    
    
    @IBOutlet weak var currentCountryVpn: UILabel!
    @IBOutlet weak var currentStatusVpn: UILabel!
    @IBOutlet weak var buttonVPN: UIButton!
    @IBOutlet weak var numberOfDayFreeVersion: UILabel!
    @IBOutlet weak var additionallabel: UILabel!
    
    var currentUser: Users? { /// Основная переменная для остлеживания статуса пользователя
        
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
        
        numberOfDayFreeVersion.text = amountOfDay
        additionallabel.text = additionalText
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeStatus), name: NSNotification.Name.NEVPNStatusDidChange, object: nil) /// Добавляем наблюдателя за впн соединением, в данном случае наш класс VC
        
        currentStatusVpn.text = "VPN отключен"
        
    }
    
    
    
    
    
    @IBAction func preferencesPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "vpnToPreferences", sender: self)
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let dvc = segue.destination as?  MenuViewController { /// Переходим в меню передавая текущие данные о пользователе
            dvc.currentUsers = currentUser!
        }
        
    }
    
    
    @IBAction func changeCountryPresed(_ sender: UIButton) {
        performSegue(withIdentifier: "vpnToChangeCountry", sender: self)
    }
    
    
    
    
    
    
    
    //MARK: - Кнопка подключения нажата
    
    
    @IBAction func vpnConnectPressed(_ sender: UIButton) {
        pressedVPNButton = !pressedVPNButton
        
        if accessUser { /// Если доступ есть то разрешаем подключение
            
            if pressedVPNButton {

                if let country = defaults.dictionary(forKey: "vpnData")  { /// Если в UserDefaults что то есть
                    
                    
                    let credentials = AVVPNCredentials.IKEv2(server: country["serverIP"] as! String, username: country["userName"] as! String, password: country["password"] as! String, remoteId:country["serverIP"] as! String, localId: country["serverIP"] as! String)

                    
                    AVVPNService.shared.connect(credentials: credentials) { error in /// Производим подключение к выбранной стране
                        if error != nil {
                            self.currentStatusVpn.text = "Подключение не удалось \(error!)"
                            print("Ошибка подключения: \(error!)")
                        }
                    }
                }else {
                        creatAlert(text: "Выберете страну подключения")
                    }
            
            }else { /// Если кнопка была нажатва второй раз то отключаемся от ВПН
                AVVPNService.shared.disconnect()
            }
            
        }else { /// Если нету доступа уведомляем пользователя
            
                
            if currentUser!.freeUser {
                    creatAlert(text: "Ваш срок бесплатного пользования истек. Вы можете купить премиум аккаунт для его продления")
                }else {
                    creatAlert(text: "Ваш срок премиум аккаунта истек. Вы можете его продлить в разделе настроек")
                }

        }
        
        
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





//MARK: - Создаем уведомление и отоброжаем количество оставшихся дней

extension ViewController {
    
    
    func creatAlert(text: String){ /// Функция для создания уведомлений
        
        let alert = UIAlertController(title: "Предупреждение!", message: text, preferredStyle: .alert)
        present(alert, animated: true)
        
        alert.addAction(UIAlertAction(title: "ок", style: .default))
        
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



//MARK: - Загрузка данных о пользователе если у него нет подписки

extension ViewController {
    
    private func loadData() {
        Task {
            if let date = await LoadData().loadDataFreeUser(phoneNumber: phoneNumber) {
                currentUser = Users(dataFirstLaunch: date, subscriptionStatus: false, freeUser: true)
                
                if accessUser {
                    numberOfDayFreeVersion.text = self.amountOfDay
                    additionallabel.text = "До истечения бесплатного пользования"
                }else {
                    numberOfDayFreeVersion.text = "Срок истек"
                    additionallabel.isHidden  = true
                }
                
                
            }
        }
    }
}






//MARK: - Проверяем статус подписки запрашивая квитанцую от Apple



extension ViewController: SKRequestDelegate{
    
    func receiptValidation(){
        
        Receipt().getReceipt()
        
        let urlString = "https://sandbox.itunes.apple.com/verifyReceipt" /// Указываем что берем даныне с песочницы
        
        guard let receiptURL = Bundle.main.appStoreReceiptURL,let receiptString =  try?  Data(contentsOf: receiptURL).base64EncodedString()  else { /// 1 Путь к файлу квитанции  2  Пытаемся преобразовать файл   Если вдруг нет пути или нет файла то мы вызываем обновление чека
            refrreshReceipt()
                       return
               }
        
        
            let url = URL(string: urlString)!
            
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
                        
                        
                        if let dataArr = jsonData["latest_receipt_info"] as? [[String: Any]] { /// Далее преобразуем в архив словарей если там есть  latest_receipt_info
                            
                            self.defaults.set(true, forKey: "subscriptionPayment") /// Говорим что пользователь покупал подписку
                            
                            let subscriptionExpirationDate = dataArr[0]["expires_date"] as! String // Берем последний массив и от туда дату окончания подписки
                            
                            
                            if let dateEndSubscription = Formatter.customDate.date(from: subscriptionExpirationDate) { /// Форматиурем нашу строку в дату
                                
                                
                                
                                if Date() > dateEndSubscription { /// Если текущая дата больше даты окончания заканчиваем подписку
                                    
                                    self.currentUser = Users(dataFirstLaunch: 0, subscriptionStatus: false, freeUser: false)
                                    self.numberOfDayFreeVersion.text = ""
                                    self.additionallabel.text  = "Срок премиум аккаунта истек"
                                    print("Now \(dateEndSubscription)")
                                }
                                
                                else {
                                    self.currentUser = Users(dataFirstLaunch: 0, subscriptionStatus: true, freeUser: false)
                                    
                            
                                    let rusDate = Formatter.formatToRusDate.string(from: dateEndSubscription)
                                    
                                    self.additionallabel.text  = "Премиум Активен до \(rusDate)"
                                    
                                    if self.defaults.bool(forKey: "FirstLaunch") {
                                        self.creatAlert(text: "Премиум аккаунт активирован")
                                        self.defaults.set(false, forKey: "FirstLaunch")
                                    }
                                    
                                    print("Yeah \(dateEndSubscription)")
                                }
                            }
                            
                            
                        }else { /// latest_receipt_info - если данной строки нет значит пользователь никогда не покупал подписку, в таком случае откланяем viewController
                            
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let dvc = storyboard.instantiateViewController(withIdentifier: "presentVC") as! PresentViewController
                            dvc.activeSubscripeAbsence = true
                            self.present(dvc, animated: true)
                        }
                        
                  }
                }
                
                
                
            }.resume()
        
        
        
        

        
    }
    
    func refrreshReceipt(){ /// Функция которая обновляет чек, я вызваю ее когда чека нету по нужно пути
        let request = SKReceiptRefreshRequest(receiptProperties: nil)
        request.delegate = self
        request.start() /// Отправляет запрос в Apple App Store. Результаты запроса отправляются делегату запроса.
    }
    
    
    func requestDidFinish(_ request: SKRequest) {
        
        if request is SKReceiptRefreshRequest { /// Если чек есть вызваем еще раз функцию проверки чека
            receiptValidation()
        }
    }
    
}

    
    
