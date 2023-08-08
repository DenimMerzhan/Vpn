//
//  MenuCategory.swift
//  test
//
//  Created by Деним Мержан on 03.08.23.
//

import Foundation



enum NameMenuCategory {
    
    case support(name:String)
    case askQuestion(name:String)
    case termsOfUse(name:String)
    case privacyPolicy(name:String)
    case accountInfo(name:String)
    
}

struct MenuCategory {
    
    var name: NameMenuCategory
    var description: String
    var isSelected =  false
    
}

