//
//  ChangeCountryNetworkService.swift
//  Vpn
//
//  Created by Деним Мержан on 01.09.23.
//

import Foundation
import FirebaseFirestore


class ChangeCountryNetworkService {
    
    static func loadAllCountry(completion: @escaping ([Country]) -> ())  {
        
        let db = Firestore.firestore()
        var countryArr = [Country]()
        
        db.collection("Country").getDocuments { QuerySnapshot, err in
            
            if let error = err {
                print("Ошибка загрузки стран - \(error)")
            }
            
            guard let querySnapshot = QuerySnapshot else {return}
            
            for document in querySnapshot.documents {
                let data = document.data()
                
                if let countryName = data["name"] as? String,let serverIP = data["serverIP"] as? String, let password = data["password"] as? String, let userName = data["userName"] as? String {
                    let country = Country(name: countryName, serverIP: serverIP, userName: userName, password: password)
                    countryArr.append(country)
                }
                
            }
            DispatchQueue.main.async {
                completion(countryArr)
            }
        }
    }
}
