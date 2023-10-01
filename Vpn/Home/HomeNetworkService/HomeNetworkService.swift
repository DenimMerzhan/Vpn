//
//  HomeNetworkService.swift
//  Vpn
//
//  Created by Деним Мержан on 28.09.23.
//

import Foundation
import FirebaseFirestore

class HomeNetworkService {
    
    private let db = Firestore.firestore()
    
    func getFreeServerAcount(serverName: String){
        
        let ref = db.collection("Country").document(serverName)
        
        ref.getDocument { documentSnap, err in
            guard let documentSnapData = documentSnap?.data() else {return}
            
            for document in documentSnapData {
                print(document)
            }

        }
    }
    
    
}
