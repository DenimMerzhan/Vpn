//
//  Receipt.swift
//  Vpn
//
//  Created by Деним Мержан on 15.04.23.
//

import Foundation


struct Receipt {
    
    func receiptValidation() -> TimeInterval? {
        
        let urlString = "https://sandbox.itunes.apple.com/verifyReceipt" /// Указываем что берем даныне с песочницы
        
        guard let receiptURL = Bundle.main.appStoreReceiptURL,let receiptString =  try?  Data(contentsOf: receiptURL).base64EncodedString()  else { /// 1 Путь к файлу квитанции  2  Пытаемся преобразовать файл   Если вдруг нет пути или нет файла то мы вызываем обновление чека
            refrreshReceipt()
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
