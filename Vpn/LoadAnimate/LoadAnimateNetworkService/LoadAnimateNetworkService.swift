//
//  LoadAnimateNetworkService.swift
//  Vpn
//
//  Created by Деним Мержан on 01.09.23.
//

import Foundation
import FirebaseFirestore


class LoadAnimateNetworkService {
    
    private let db = Firestore.firestore()
    
    func loadDateFirstLaunch(completion: @escaping(_ isConntectToInternet: Bool,_ dateFirstLaunch: Double?) -> ()){
        
        NetworkService.shared.getDateFirstLaunch { dateFirstLaunch, isConntectToInternet in
            
            if isConntectToInternet == false {
                completion(false,nil)
                return
            }
            completion(true,dateFirstLaunch)
            
        }
        
    }
    
//    func loadCountry(name: String, completion: @escaping(_ country: Server?) -> ()){
//        
//        db.collection("Country").whereField("name", isEqualTo: name).getDocuments { QuerySnapshot, error in
//            if let error = error {print("Ошибка загрузки страны - \(error)")}
//            
//            guard let querySnapshot = QuerySnapshot else {
//                completion(nil)
//                return}
//            
//            for document in querySnapshot.documents {
//                let data = document.data()
//                
//                if let countryName = data["name"] as? String,let serverIP = data["serverIP"] as? String, let password = data["password"] as? String, let userName = data["userName"] as? String {
//                    let country = Server(name: countryName, serverIP: serverIP, userName: userName, password: password)
//                    completion(country)
//                    return
//                }
//                
//            }
//            completion(nil)
//        }
//        
//    }
    
}
