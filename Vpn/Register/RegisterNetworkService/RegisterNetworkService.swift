//
//  RegisterNetworkService.swift
//  Vpn
//
//  Created by Деним Мержан on 01.09.23.
//

import Foundation
import FirebaseFirestore


class RegisterNetworkService {
    
    private let db = Firestore.firestore()
    
    
    func createNewUser(phoneNumber: String, completion: @escaping() -> ()){
        
        db.collection("Users").document(phoneNumber).setData(["dateActivationTrial" : Date().timeIntervalSince1970,
            "ID": phoneNumber],completion: { err in
            if let error = err {
                print("Ошибка создания нового пользователя - \(error)")
            }
            completion()
        })
    }
    
    
    func checkIsExistUser(userID: String,completion: @escaping(_ isExistUser: Bool) ->() ){
    
            db.collection("Users").whereField("ID", isEqualTo: userID).getDocuments { QuerySnapshot, Error in
    
                guard QuerySnapshot != nil else {return}
    
                if QuerySnapshot!.isEmpty {
                    completion(false)
                }else {
                    completion(true)
                }
            }
        }
    
}
