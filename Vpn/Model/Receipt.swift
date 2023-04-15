//
//  Receipt.swift
//  Vpn
//
//  Created by Деним Мержан on 15.04.23.
//

import Foundation
import StoreKit


struct Receipt {
    
    
    func getReceipt() {
        Task {
            let reciept = await receiptValidation()
            print("Квитацния - ", reciept)
        }
    }
    
    func receiptValidation() async -> Date? {
        
        let urlString = "https://sandbox.itunes.apple.com/verifyReceipt" /// Указываем что берем даныне с песочницы
        
        guard let receiptURL = Bundle.main.appStoreReceiptURL,let receiptString =   try? Data(contentsOf: receiptURL).base64EncodedString()  else { /// 1 Путь к файлу квитанции  2  Пытаемся преобразовать файл   Если вдруг нет пути или нет файла то мы вызываем обновление чека
            return nil
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
            
        
        let newData = try! await URLSession.shared.data(for: request)
                    
        let data = newData.0
        if let jsonData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] {  /// Преобразуем файл Json в словарь
                        
                        
            if let dataArr = jsonData["latest_receipt_info"] as? [[String: Any]] { /// Далее преобразуем в архив словарей если там есть  latest_receipt_info
                
                
                let subscriptionExpirationDate = dataArr[0]["expires_date"] as! String // Берем последний массив и от туда дату окончания подписки
                
                
                if let dateEndSubscription = Formatter.customDate.date(from: subscriptionExpirationDate) { /// Форматиурем нашу строку в дату
                    print(dateEndSubscription)
                    return dateEndSubscription
                }
                }else { /// latest_receipt_info - если данной строки нет значит пользователь никогда не покупал подписку, в таком случае откланяем viewController
                    print("Нет квитанциий")
                }
            }
        
        return nil
    }
    
    
    
    
}
