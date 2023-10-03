//
//  ChangeCountryNetworkService.swift
//  Vpn
//
//  Created by Деним Мержан on 01.09.23.
//

import Foundation
import FirebaseFirestore


class ChangeCountryNetworkService {
    
    static func loadServersName(completion: @escaping ([String]) -> ())  {
        
        let db = Firestore.firestore()
        var serverNameArr = [String]()
        
        db.collection("Servers").getDocuments { QuerySnapshot, err in
            
            if let error = err {
                print("Ошибка загрузки стран - \(error)")
            }
            
            guard let querySnapshot = QuerySnapshot else {return}
            
            for document in querySnapshot.documents {
                let data = document.data()
                
                if let serverName = data["Name"] as? String {
                    serverNameArr.append(serverName)
                }
                
            }
            DispatchQueue.main.async {
                completion(serverNameArr)
            }
        }
    }
}
