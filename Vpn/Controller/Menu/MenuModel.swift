//
//  MenuModel.swift
//  Vpn
//
//  Created by Деним Мержан on 08.08.23.
//

import Foundation

struct MenuModel {
    
    func fillMenuCategory(menuCategory: [MenuCategory],phoneNumber:String? ) -> [MenuCategory] {
        
        var menuCategories = menuCategory
        
        menuCategories.append(MenuCategory(name: .support(name: "Поддержка"), description: "Для поддержки пишите к нам на почту topvpn@inbox.ru"))
        
        menuCategories.append(MenuCategory(name: .askQuestion(name: "Ответы на вопросы"), description: "Все вопросы вы можете задать на нашу почту topvpn@inbox.ru"))
    
        menuCategories.append(MenuCategory(name: .termsOfUse(name: "Пользовательское соглашение"), description: "TopVpn не предоставляет никаких гарантий на услуги или программное обеспечение. TopVpn не несет ответственности за ущерб, который может возникнуть в результате раскрытия личности или IP-адреса пользователя или выхода из строя отдельных VPN-серверов"))
        
        menuCategories.append(MenuCategory(name: .privacyPolicy(name: "Политика конфиденциальности"), description: "TOP Vpn  придерживается однозначной политики компании: строжайшее соблюдение защиты данных и бескомпромиссная защита конфиденциальности пользователей..."))
        
        if let number = phoneNumber {
            menuCategories.append(MenuCategory(name: .accountInfo(name: "Информация об аккаунте"), description:"Ваш номер телефона привязанный к аккаунту \(number)"))
        }
        
        return menuCategories
        
    }
    
}
