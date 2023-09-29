//
//  HomeModel.swift
//  Vpn
//
//  Created by Деним Мержан on 31.08.23.
//

import Foundation
import UIKit


struct HomeModel {
    
    func amountOfDayEndTrialPeriod(expirationDate: Date) -> String { /// Подсчитываем сколько дней осталось до конца бесплатного периода
        
        var amountOfDay = String()
        
        let expirationDateSecond = expirationDate.timeIntervalSince1970
        let diff = Int((expirationDateSecond - Date().timeIntervalSince1970) / 86400) /// 86400 - Количество секунд в дне
        let remainder = diff % 10

        if (10...20).contains(diff) || remainder == 0 {
            amountOfDay = String(diff) + " дней"
        }else if (5...9).contains(remainder) {
            amountOfDay = String(diff) + " дней"
        }else if (2...4).contains(remainder) {
            amountOfDay = String(diff) + " дня"
        }else if remainder == 1 {
            amountOfDay = String(diff) + " день"
        }
        
        return amountOfDay
        
    }
    
    func createAlert(text:String) -> UIAlertController { /// Функция для создания уведомлений
        
        let alert = UIAlertController(title: "Предупреждение!", message:text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ок", style: .default))
        return alert
    }
    
}
