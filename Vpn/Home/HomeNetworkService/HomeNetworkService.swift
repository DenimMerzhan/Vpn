//
//  HomeNetworkService.swift
//  Vpn
//
//  Created by Деним Мержан on 28.09.23.
//

import Foundation
import FirebaseFirestore

protocol HomeNetworkServiceProtocol: AnyObject {
    func loadServerWithError(error: String)
}

class HomeNetworkService {
    
    private let db = Firestore.firestore()
    weak var delegate: HomeNetworkServiceProtocol?
    
    func getServerData(serverName: String,completion: @escaping(Server) -> ()){
        
        let ref = db.collection("Servers").document(serverName).collection("Users").whereField("IsConnectionFree", isEqualTo: true).limit(to: 1)
        
        ref.getDocuments { [weak self] querySnapshot, error in
            if let error = error {
                self?.delegate?.loadServerWithError(error: error.localizedDescription)
            }
            
            if let document = querySnapshot?.documents.first {
                let data = document.data()
                
                if let userName = data["Name"] as? String, let password = data["Password"] as? String {
                    self?.getServerIP(serverName: serverName, completion: { serverIP in
                        let server = Server(name: serverName, serverIP: serverIP, userName: userName, password: password)
                        DispatchQueue.main.async {
                            completion(server)
                        }
                    })
                }
                
            }else {
                self?.delegate?.loadServerWithError(error: "Cервер Перегружен")
            }
            
        }
    }
    
    private func getServerIP(serverName: String,completion: @escaping(_ serverIP: String) -> ()){
        
        let serverRef = db.collection("Servers").document(serverName)
        
        serverRef.getDocument { [weak self] querySnapshot, error in
            if let error = error {
                self?.delegate?.loadServerWithError(error: error.localizedDescription)
            }
            
            guard let querySnapshot = querySnapshot else {
                self?.delegate?.loadServerWithError(error: "Не удалось получить документ с сервера")
                return}
            
            if let serverIP = querySnapshot.data()?["ServerIP"] as? String {
                completion(serverIP)
            }else {
                self?.delegate?.loadServerWithError(error: "Отсутсвует IP сервера")
            }
        }
    }
}
