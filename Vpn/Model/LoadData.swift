//
//  LoadData.swift
//  Vpn
//
//  Created by Деним Мержан on 14.04.23.
//

import Foundation
import FirebaseFirestore


struct LoadData {
    
    let db = Firestore.firestore()
    
    func loadDataFreeUser(phoneNumber: String) async -> TimeInterval? {
        
        var existingUser = false /// Проверка существует ли пользователь с данным номером телефона в базе
        
        do{
            let querySnapshot = try await db.collection("Users").getDocuments()
            
            for document in querySnapshot.documents {
               
                if document.documentID == phoneNumber { /// Если текущий пользователь уже был зарегестрирован
                    
                   existingUser = true
                   return document["dateFirstLaunch"] as? TimeInterval /// Возвращаем дату регистрации
                    
                }
            }

        }catch{
            print("Ошибка получения данных")
        }
        
        if existingUser == false { /// Если новый пользователь
            do {
                try await db.collection("Users").document(phoneNumber).setData(["dateFirstLaunch":NSDate().timeIntervalSince1970])
                print("OldUser")
                return NSDate().timeIntervalSince1970
            }catch{
                print("Ошибка сохранения данных")
            }
        }
        
        return nil
        
            }
    
    
     func loadCountry() async -> [Country]? {
         
         var countryArr = [Country]()
        do {
            let querySnapshot = try await db.collection("Country").getDocuments()
        
                for doc in querySnapshot.documents {
                        let data = doc.data()
                        if let name = data["name"] as? String, let serverIP = data["serverIP"] as? String, let password = data["password"] as? String, let userName = data["userName"] as? String, let selected = data["selected"] as? Bool {
                            
                            countryArr.append(Country(name: name, serverIP: serverIP, userName: userName, password: password, selected: selected))
                            
                        }else {
                            print("Ошибка преобразования данных")
                        }
                    }
            return countryArr
        }catch{
            print("Ошибка загрузки данных о странах")
        }
        return nil
    }
    
        }
    

