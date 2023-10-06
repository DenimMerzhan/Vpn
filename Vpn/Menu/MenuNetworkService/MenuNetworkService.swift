//
//  MenuNetworkService.swift
//  Vpn
//
//  Created by Деним Мержан on 31.08.23.
//

import Foundation

enum MenuNetworkServiceError: Error {
    case decodingError
    case isMissingReceipt
}


class MenuNetworkService {
    
    private init(){}
    
    static func getReceipt(completion: @escaping(Result<Date, MenuNetworkServiceError>) -> ()){
        
        let urlStringSandBox = "https://sandbox.itunes.apple.com/verifyReceipt" /// Указываем что берем даныне с песочницы
        let urlStringAppStore = "https://buy.itunes.apple.com/verifyReceipt" /// Указываем что берем даныне с Itunes
        
        guard let url = URL(string: urlStringSandBox) else {return}
        
        NetworkService.shared.getReceipt(url: url) { result in
            
            switch result {
            case .success(let data):
                if let dateEndSubscribe = MenuModel.decodeJson(data: data) {
                    completion(.success(dateEndSubscribe))
                }else {
                    completion(.failure(.decodingError))
                }
            case .failure(let error):
                switch error {
                case .isMissingReceipt:
                    completion(.failure(.isMissingReceipt))
                default: break
                }
            }
        }
        
    }
    
}


