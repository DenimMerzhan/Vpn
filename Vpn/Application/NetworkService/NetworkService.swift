//
//  NetworkService.swift
//  Vpn
//
//  Created by Деним Мержан on 31.08.23.
//

import Foundation
import FirebaseFirestore


class NetworkService {
    
    static let shared = NetworkService()
    private let db = Firestore.firestore()
    
    private init(){}
    
    
    func getReceipt(url : URL,completion: @escaping (_ data: Data?,_ isMissingReceipt: Bool) -> ()) { /// Функция для получения даты окончания подписки
        
        guard let receiptURL = Bundle.main.appStoreReceiptURL,let receiptString =   try? Data(contentsOf: receiptURL).base64EncodedString()  else { /// 1 Путь к файлу квитанции  2  Пытаемся преобразовать файл   Если вдруг нет пути или нет файла то значит нет чека. Либо пользователь не покупал ни разу подписку, либо у него новое устройство тогда он должен нажать восстановить покупки
            completion(nil,true)
            return
        }
        
        let requestData : [String : Any] = ["receipt-data" : receiptString, /// Создаем словарь
                                            "password" : "11f70af409dc42dfadee27090ff87b66", /// пароль это секретный ключ
                                            "exclude-old-transactions" : false] /// Исключать старые транзакции нет
        
        let httpBody =  try? JSONSerialization.data(withJSONObject: requestData, options: []) /// Объект, который выполняет преобразование между JSON и эквивалентными объектами Foundation.
        
        var request = URLRequest(url: url) /// Запрос загрузки URL, который не зависит от протокола или схемы URL.
        request.httpMethod = "POST" /// POST — означает что некоторые данные должны быть помещены на сервер.
        
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type") /// Задает значение для поля заголовка. Field Имя поля заголовка для установки. В соответствии с HTTP RFC имена полей заголовков HTTP нечувствительны к регистру.
        
        request.httpBody = httpBody /// Данные, отправляемые в виде тела сообщения запроса, например, для HTTP-запроса POST.
        
        let task = URLSession.shared.dataTask(with: request) { data, urlResponse, err in
            
            if let error = err {
                print("Ошибка получения квитанции - \(error)")
            }
            
            completion(data,false)

        }
        task.resume() ///  Недавно инициализированные задачи начинаются в приостановленном состоянии, поэтому вам нужно вызвать этот метод, чтобы запустить задачу.
    }
    
    
    
    func getMetadataAboutUser(completion: @escaping (_ dateFirstLaunch: Double?,_ lastSelectedCountry: String?,_ isConntectToInternet: Bool?) -> ()) { /// Загрузка или добавление  бесплатных пользователей
        
        db.collection("Users").whereField("ID", isEqualTo: CurrentUser.shared.ID).getDocuments(completion: { querySnapshot, err in
            

            guard querySnapshot != nil else {return}
            
            if querySnapshot!.metadata.isFromCache { /// Если данные из кэша значит пользователь не подключен к интернету
                completion(nil,nil,false)
                return
            }
            
            if let documentData = querySnapshot!.documents.first?.data() {
                
                if let dateFirstLaunch = documentData["dateActivationTrial"] as? TimeInterval {
                    
                    if let lastSelectedCountry = documentData["lastSelectedCountry"] as? String {
                        completion(dateFirstLaunch,lastSelectedCountry,true)
                        return
                    }
                    completion(dateFirstLaunch,nil,true)
                    return
                }
            }
            if let error = err {
                print("Ошибка получения дата окончания пробного периода - \(error)")
                completion(nil,nil,true)
            }
        })
    }
    
}
