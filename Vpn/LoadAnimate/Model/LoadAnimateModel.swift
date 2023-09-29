//
//  LoadAnimateModel.swift
//  Vpn
//
//  Created by Деним Мержан on 01.09.23.
//

import Foundation

struct LoadAnimateModel {
    
    private let thirtyDaySecond: Double = 2592000
    
    func updateUserTrialStatus(dateFirstLaunch: Double){
        
        let differenceBetwenToday = Date().timeIntervalSince1970 - dateFirstLaunch
        if differenceBetwenToday > thirtyDaySecond {CurrentUser.shared.freeUserStatus = .endend}
        else {
            let expirationDate = Date(timeIntervalSince1970: dateFirstLaunch + thirtyDaySecond)
            CurrentUser.shared.freeUserStatus = .valid(expirationDate: expirationDate)
        }
    }
    
}
