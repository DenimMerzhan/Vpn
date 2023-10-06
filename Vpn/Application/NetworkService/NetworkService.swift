//
//  NetworkService.swift
//  Vpn
//
//  Created by Деним Мержан on 31.08.23.
//

import Foundation
import FirebaseFirestore


enum NetworkServiceError: Error {
    case isMissingReceipt
    case appleError(String)
    case isMissingData
    
    case noInternetConnection
    case dateFirstLaunchMissing
    case firebaseError
    
}

class NetworkService {
    
    static let shared = NetworkService()
    private let db = Firestore.firestore()
    
    private init(){}
    
    
    func getReceipt(url : URL,completion: @escaping (Result<Data, NetworkServiceError>) -> ()) { /// Функция для получения даты окончания подписки
        
        guard let receiptURL = Bundle.main.appStoreReceiptURL,let receiptString =   try? Data(contentsOf: receiptURL).base64EncodedString()  else { /// 1 Путь к файлу квитанции  2  Пытаемся преобразовать файл   Если вдруг нет пути или нет файла то значит нет чека. Либо пользователь не покупал ни разу подписку, либо у него новое устройство тогда он должен нажать восстановить покупки
            sendFailure(error: .isMissingReceipt)
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
                print("Ошибка получения квитанции - \(error.localizedDescription)")
                sendFailure(error: .appleError(error.localizedDescription))
            }
            if let data = data {
                completion(.success(data))
            }else {
                completion(.failure(.isMissingData))
            }
            
        }
        task.resume() ///  Недавно инициализированные задачи начинаются в приостановленном состоянии, поэтому вам нужно вызвать этот метод, чтобы запустить задачу.
        
        func sendFailure(error: NetworkServiceError){
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
    
    
    
    func getDateFirstLaunch(completion: @escaping (Result<Double, NetworkServiceError>) -> ()) { /// Загрузка или добавление  бесплатных пользователей
        
        db.collection("Users").whereField("ID", isEqualTo: CurrentUser.shared.ID).getDocuments(completion: { querySnapshot, err in
            

            guard querySnapshot != nil else {return}
            
            if querySnapshot!.metadata.isFromCache { /// Если данные из кэша значит пользователь не подключен к интернету
                sendFailure(error: .noInternetConnection)
                return
            }
            
            if let documentData = querySnapshot!.documents.first?.data() {
                
                if let dateFirstLaunch = documentData["dateActivationTrial"] as? TimeInterval {
                    DispatchQueue.main.async {
                        completion(.success(dateFirstLaunch))
                    }
                    return
                }else {
                    sendFailure(error: .dateFirstLaunchMissing)
                }
            }
            if let error = err {
                print("Ошибка получения дата окончания пробного периода - \(error)")
                sendFailure(error: .firebaseError)
            }
        })
        
        func sendFailure(error: NetworkServiceError) {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
    
}

