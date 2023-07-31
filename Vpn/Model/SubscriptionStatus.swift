//
//  SubscriptionStatus.swift
//  Vpn
//
//  Created by Деним Мержан on 26.07.23.
//

import Foundation


enum SubscriptionStatus{
    case valid(expirationDate: Date)
    case ended
    case notBuy

}

enum FreeUserStatus {
    
    case valid(expirationDate: Date)
    case endend
    case blocked
    
}
