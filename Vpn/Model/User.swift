//
//  Users.swift
//  Vpn
//
//  Created by Деним Мержан on 05.04.23.
//

import Foundation
import StoreKit
import FirebaseFirestore

class User {
    
    
    static var shared = User()
    
    var ID = String()
    var dataFirstLaunch: TimeInterval?
    var subscriptionStatus =  SubscriptionStatus.notBuy {
        didSet {
            freeUserStatus = .blocked
        }
    }
    var freeUserStatus = FreeUserStatus.blocked
    var selectedCountry: Country?
    
    var acesstToVpn: Bool {
        get {
            switch subscriptionStatus {
            case.valid(expirationDate: _):return true
            case.ended: return false
            default:break
            }
            
            switch freeUserStatus {
            case.valid(expirationDate: _): return true
            default: return false
            }
        }
    }
    
    private let db = Firestore.firestore()
    
    private init() {}
    
    
    
    func amountOfDayEndTrialPeriod() -> String { /// Подсчитываем сколько дней осталось до конца бесплатного периода
        
        var amountOfDay = String()
        
        if case let FreeUserStatus.valid(expirationDate) = freeUserStatus {
            let expirationDateSecond = expirationDate.timeIntervalSince1970
            let diff = expirationDateSecond / 86400 - Date().timeIntervalSince1970
            if diff > 4 || diff == 0 {
                amountOfDay = "\(String(diff)) дней"
            }else if diff > 1 {
                amountOfDay = "\(String(diff)) дня"
            }else {
                amountOfDay = "\(String(diff)) день"
            }
        }
        return amountOfDay
        
    }
    
}


//MARK: -  Запрашиваем квитанцию

extension User {
    
    func refreshReceipt(completion: @escaping (_ needToUpdateReceipt: Bool) -> ()) { /// Функция для получения даты окончания подписки
        
        let urlString = "https://sandbox.itunes.apple.com/verifyReceipt" /// Указываем что берем даныне с песочницы
        
        guard let receiptURL = Bundle.main.appStoreReceiptURL,let receiptString =   try? Data(contentsOf: receiptURL).base64EncodedString()  else { /// 1 Путь к файлу квитанции  2  Пытаемся преобразовать файл   Если вдруг нет пути или нет файла то мы вызываем обновление чека
            completion(true)
            return
        }
        
        
        let url = URL(string: urlString)!
        
        let requestData : [String : Any] = ["receipt-data" : receiptString, /// Создаем словарь
                                            "password" : "11f70af409dc42dfadee27090ff87b66", /// пароль это секретный ключ
                                            "exclude-old-transactions" : false] /// Исключать старые транзакции нет
        
        let httpBody =  try? JSONSerialization.data(withJSONObject: requestData, options: []) /// Объект, который выполняет преобразование между JSON и эквивалентными объектами Foundation.
        
        
        var request = URLRequest(url: url) /// Запрос загрузки URL, который не зависит от протокола или схемы URL.
        request.httpMethod = "POST" /// POST — означает что некоторые данные должны быть помещены на сервер.
        
        
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type") /// Задает значение для поля заголовка. Field Имя поля заголовка для установки. В соответствии с HTTP RFC имена полей заголовков HTTP нечувствительны к регистру.
        
        
        request.httpBody = httpBody /// Данные, отправляемые в виде тела сообщения запроса, например, для HTTP-запроса POST.
        
        
        let newData = URLSession.shared.dataTask(with: request) { newData, urlResponse, err in
            
            guard let data = newData else {return}
            if let error = err {
                print("Ошибка получения квитанции - \(error)")
            }
            
            if let jsonData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] {  /// Преобразуем файл Json в словарь
                
                
                if let dataArr = jsonData["latest_receipt_info"] as? [[String: Any]] { /// Далее преобразуем в архив словарей если там есть  latest_receipt_info
                    
                    
                    let subscriptionExpirationDate = dataArr[0]["expires_date"] as! String // Берем последний массив и от туда дату окончания подписки
                    
                    
                    if let dateEndSubscription = Formatter.customDate.date(from: subscriptionExpirationDate) { /// Форматиурем нашу строку в дату
                        
                        if Date() > dateEndSubscription { /// Если текущая дата больше даты окончания заканчиваем подписку
                            User.shared.subscriptionStatus = .ended
                            print("Now \(dateEndSubscription)")
                        }
                        else {
                            
                            User.shared.subscriptionStatus = .valid(expirationDate: dateEndSubscription)
                            print("Yeah \(dateEndSubscription)")
                        }
                    }
                }else { /// latest_receipt_info - если данной строки нет значит пользователь никогда не покупал подписку
                    print("Квитанция о подписке пользователя отсутствует")
                }
            }
        }
        completion(false)
    }
}


//MARK: -  Получение даты окончания пробного периода

extension User {
    
    func loadMetadata(completion: @escaping () -> ()) { /// Загрузка или добавление  бесплатных пользователей
        
        db.collection("Users").whereField("ID", isEqualTo: ID).getDocuments(completion: { querySnapshot, err in
            
            guard querySnapshot != nil else {return}
            
            if let documentData = querySnapshot!.documents.first?.data() {
                
                if let dateFirstLaunch = documentData["dateActivationTrial"] as? TimeInterval {
                    
                    let differenceBetwenToday = Date().timeIntervalSince1970 - dateFirstLaunch
                    if differenceBetwenToday > 86400 {self.freeUserStatus = .endend}
                    else {
                        let expirationDate = Date(timeIntervalSince1970: 604800 - differenceBetwenToday)
                        self.freeUserStatus = .valid(expirationDate: expirationDate)
                    }
                }
                if let lastSelectedCountry = documentData["lastSelectedCountry"] as? String {
                    self.selectedCountry = Country(name: lastSelectedCountry)
                }
            }
            completion()
            if let error = err {print("Ошибка получения дата окончания прбного периода - \(error)")}
        })
    }
}



