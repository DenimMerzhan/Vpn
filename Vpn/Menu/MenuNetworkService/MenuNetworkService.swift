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
        
        guard let url = Link.sandBox.url else {return}
        
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

extension MenuNetworkService {
    
    enum Link {
        case sandBox
        case appStore
        
        var url : URL? {
            switch self {
            case .sandBox:
                return URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")
            case .appStore:
                return URL(string: "https://buy.itunes.apple.com/verifyReceipt")
            }
        }
    }
}
