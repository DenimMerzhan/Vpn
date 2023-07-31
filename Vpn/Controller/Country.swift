//
//  Country.swift
//  Vpn
//
//  Created by Деним Мержан on 31.03.23.
//

import Foundation
import FirebaseFirestore


class Country {

    let name: String
    
    var serverIP: String?
    var userName: String?
    var password: String?
    
    private let db = Firestore.firestore()

    
    init(name: String) {
        self.name = name
        loadData()
    }
    
    func loadData()  { /// Загрузка стран и их данных для подключения к впн
        
        db.collection("Country").whereField("name", isEqualTo: name).getDocuments { querySnapshot, err in
            
            guard querySnapshot != nil else {return}
            
            if let error = err {print("Ошибка загрузки данных о страна - \(error)")}
            
            for doc in querySnapshot!.documents {
                    let data = doc.data()
                    if let serverIP = data["serverIP"] as? String, let password = data["password"] as? String, let userName = data["userName"] as? String {
                        
                        self.serverIP = serverIP
                        self.userName = userName
                        self.password = password
                        
                    }else {
                        print("Ошибка преобразования данных")
                    }
                }
        }
   }
}
