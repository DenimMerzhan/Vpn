//
//  Country.swift
//  Vpn
//
//  Created by Деним Мержан on 31.03.23.
//

import Foundation
import FirebaseFirestore


struct Country {

    let name: String
    var serverIP: String
    var userName: String
    var password: String

    init(name: String, serverIP: String, userName: String, password: String) {
        self.name = name
        self.serverIP = serverIP
        self.userName = userName
        self.password = password
    }
    

}
