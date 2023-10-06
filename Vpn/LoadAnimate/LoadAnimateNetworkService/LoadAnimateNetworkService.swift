//
//  LoadAnimateNetworkService.swift
//  Vpn
//
//  Created by Деним Мержан on 01.09.23.
//

import Foundation
import FirebaseFirestore

enum LoadAnimateNetworkError: Error {
    case noInternetConnection
    case dateFirstLaunchMissing
}


class LoadAnimateNetworkService {
    
    private let db = Firestore.firestore()
    
    func loadDateFirstLaunch(completion: @escaping(Result<Double,LoadAnimateNetworkError>) -> Void) {
        
        NetworkService.shared.getDateFirstLaunch { result in
            switch result {
            case .failure(let error):
                switch error {
                case .noInternetConnection: completion(.failure(.noInternetConnection))
                case .dateFirstLaunchMissing: completion(.failure(.dateFirstLaunchMissing))
                default: break
                }
            case .success(let dateFirtsLaunch):
                completion(.success(dateFirtsLaunch))
            }
        }
    }
}
