//
//  LoadData.swift
//  Vpn
//
//  Created by Деним Мержан on 14.04.23.
//

import Foundation
import FirebaseFirestore


struct LoadData {
    
   
    

    
    
     func loadCountry() async -> [Country]? { /// Загрузка стран и их данных для подключения к впн
         
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
    

