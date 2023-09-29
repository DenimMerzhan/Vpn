//
//  Users.swift
//  Vpn
//
//  Created by Деним Мержан on 05.04.23.
//

import Foundation
import StoreKit
import FirebaseFirestore

class CurrentUser {
    
    static var shared = CurrentUser()
    
    var ID = String()
    var dataFirstLaunch: TimeInterval?
    var dateEndSubscription: Date?
    
    var subscriptionStatus =  SubscriptionStatus.notBuy {
        didSet {
            switch subscriptionStatus {
            case .valid(expirationDate: _),.ended: freeUserStatus = .blocked
            default:break
            }
        }
    }
    
    var freeUserStatus = FreeUserStatus.blocked
    
    var acesstToVpn: Bool {
        get {
            switch subscriptionStatus {
            case.valid(expirationDate: _):return true
            case.ended: return false
            default:break
            }
            
            switch freeUserStatus {
            case.valid(expirationDate: _): return true
            default: return false
            }
        }
    }
    
    private let db = Firestore.firestore()
    
    private init() {}

}

