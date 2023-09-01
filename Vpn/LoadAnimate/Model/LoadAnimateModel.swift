//
//  LoadAnimateModel.swift
//  Vpn
//
//  Created by Деним Мержан on 01.09.23.
//

import Foundation

struct LoadAnimateModel {
    
    private let sevenDaySecond: Double = 604800
    
    func updateUserTrialStatus(dateFirstLaunch: Double){
        
        let differenceBetwenToday = Date().timeIntervalSince1970 - dateFirstLaunch
        if differenceBetwenToday > sevenDaySecond {CurrentUser.shared.freeUserStatus = .endend}
        else {
            let expirationDate = Date(timeIntervalSince1970: dateFirstLaunch + 604800)
            CurrentUser.shared.freeUserStatus = .valid(expirationDate: expirationDate)
        }
    }
    
}
