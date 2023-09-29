//
//  MenuNetworkService.swift
//  Vpn
//
//  Created by Деним Мержан on 31.08.23.
//

import Foundation


class MenuNetworkService {
    
    private init(){}
    
    static func getReceipt(completion: @escaping(_ isMissingReceipt:Bool ,_ dateEndSubscription: Date?) -> ()){
        
        let urlStringSandBox = "https://sandbox.itunes.apple.com/verifyReceipt" /// Указываем что берем даныне с песочницы
        let urlStringAppStore = "https://buy.itunes.apple.com/verifyReceipt" /// Указываем что берем даныне с Itunes
        
        guard let url = URL(string: urlStringSandBox) else {return}
        
        NetworkService.shared.getReceipt(url: url) { data, isMissingReceipt in
            if let data = data {
                if let dateEndSubscribe = MenuModel.decodeJson(data: data) {
                    DispatchQueue.main.async {
                        completion(false,dateEndSubscribe)
                        return
                    }
                }
            }
            DispatchQueue.main.async {
                completion(isMissingReceipt,nil)
            }
        }
        
    }
    
}


