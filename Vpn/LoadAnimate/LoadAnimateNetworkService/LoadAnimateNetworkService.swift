//
//  LoadAnimateNetworkService.swift
//  Vpn
//
//  Created by Деним Мержан on 01.09.23.
//

import Foundation
import FirebaseFirestore


class LoadAnimateNetworkService {
    
    private let db = Firestore.firestore()
    private let loadAnimateModel = LoadAnimateModel()
    
    
    func loadMetadata(completion: @escaping(_ isConntectToInternet: Bool) -> ()){
        
        NetworkService.shared.getMetadataAboutUser { [weak self] dateFirstLaunch, lastSelectedCountry, isConntectToInternet in
            
            if isConntectToInternet == false {
                completion(false)
                return
            }
            
            if let dateFirstLaunch = dateFirstLaunch {
                self?.loadAnimateModel.updateUserTrialStatus(dateFirstLaunch: dateFirstLaunch)
            }
            
            if let lastSelectedCountry = lastSelectedCountry {
                self?.loadCountry(name: lastSelectedCountry) { country in
                    CurrentUser.shared.selectedCountry = country
                }
            }
            completion(true)
            
        }
        
    }
    
    func loadCountry(name: String, completion: @escaping(_ country: Country) -> ()){
        
        db.collection("Country").whereField("name", isEqualTo: name).getDocuments { QuerySnapshot, error in
            if let error = error {print("Ошибка загрузки страны - \(error)")}
            
            guard let QuerySnapshot = QuerySnapshot else {return}
            
            for document in QuerySnapshot.documents {
                let data = document.data()
                
                if let countryName = data["name"] as? String,let serverIP = data["serverIP"] as? String, let password = data["password"] as? String, let userName = data["userName"] as? String {
                    let country = Country(name: countryName, serverIP: serverIP, userName: userName, password: password)
                    completion(country)
                }
                
            }
            
        }
        
    }
    
}
