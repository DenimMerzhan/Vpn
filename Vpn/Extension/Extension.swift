//
//  Extension.swift
//  Vpn
//
//  Created by Деним Мержан on 26.07.23.
//

import Foundation
import UIKit


//MARK: - Расширение для преобразования даты

extension Formatter {
    
    
    static let customDate: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") /// На каком языке будет отображться
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV" /// Какой формат M - месяц Y - Year b т.д
        
        return formatter
    }()
    
    static let formatToRusDate: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM"
        formatter.locale = Locale(identifier: "ru_Ru")
        
        return formatter
    }()
}

