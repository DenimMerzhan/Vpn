//
//  MenuModel.swift
//  Vpn
//
//  Created by Деним Мержан on 08.08.23.
//

import Foundation

struct MenuModel {
    
    private init(){}
    
    static func fillMenuCategory(menuCategory: [MenuCategory],phoneNumber:String? ) -> [MenuCategory] {
        
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
    
    static func decodeJson(data: Data) -> Date? {
        
        if let jsonData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] {  /// Преобразуем файл Json в словарь
            
            
            if let dataArr = jsonData["latest_receipt_info"] as? [[String: Any]] { /// Далее преобразуем в архив словарей если там есть  latest_receipt_info
                
                
                let subscriptionExpirationDate = dataArr[0]["expires_date"] as! String // Берем последний массив и от туда дату окончания подписки
                
                if let dateEndSubscription = Formatter.customDate.date(from: subscriptionExpirationDate) { /// Форматиурем нашу строку в дату
                    return dateEndSubscription
                }
            }else { /// latest_receipt_info - если данной строки нет значит пользователь никогда не покупал подписку
                print("Квитанция о подписке пользователя отсутствует")
                return nil
            }
        }
        return nil
    }
    
}
