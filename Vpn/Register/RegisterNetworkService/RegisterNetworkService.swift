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
    
    func checkIsExistUser(userID: String,completion: @escaping(_ isExistUser: Bool?,_ isSuccess:Bool) ->() ){
        
        db.collection("Users").whereField("ID", isEqualTo: userID).getDocuments { QuerySnapshot, error in
            
            if let err = error {
                print("Ошибка проверки пользователя - \(err)")
                completion(nil, false)
            }
            
            guard QuerySnapshot != nil else {
                completion(nil,false)
                return}
            
            if QuerySnapshot!.isEmpty {
                completion(false,true)
            }else {
                completion(true,true)
            }
        }
    }
    
    func createNewUser(phoneNumber: String, completion: @escaping(_ isSuccess: Bool) -> ()){
        
        db.collection("Users").document(phoneNumber).setData(["dateActivationTrial" : Date().timeIntervalSince1970,
                                                              "ID": phoneNumber],completion: { err in
            if let error = err {
                print("Ошибка создания нового пользователя - \(error)")
                completion(false)
            }else{
                completion(true)
            }
        })
    }
    
}
