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
    
    init(){
//        let settings = FirestoreSettings()
//        settings.isPersistenceEnabled = false
//        
//        db.settings = settings
    }
    
    func getServerData(serverName: String,completion: @escaping(Server) -> ()){
        
        let ref = db.collection("Servers").document(serverName).collection("Users").whereField("IsConnectionFree", isEqualTo: true).limit(to: 1)
        
        ref.getDocuments { [weak self] querySnapshot, error in
            
            if let error = error {
                self?.delegate?.loadServerWithError(error: error.localizedDescription)
            }
            
            if querySnapshot?.metadata.isFromCache == true {
                self?.delegate?.loadServerWithError(error: "Отсутсвует подключение к интернету")
                return
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
            
            if querySnapshot?.metadata.isFromCache == true {
                self?.delegate?.loadServerWithError(error: "Не удалось получить документ с сервера")
                return
            }
            
            if let serverIP = querySnapshot?.data()?["ServerIP"] as? String {
                completion(serverIP)
            }else {
                self?.delegate?.loadServerWithError(error: "Отсутсвует IP сервера")
            }
        }
    }
}

//MARK: - ConnectionStatus

extension HomeNetworkService {
    
    func writeConnectionStatus(server:Server){
        
        let userRef = db.collection("Servers").document(server.name).collection("Users").document(server.userName)
        userRef.setData(["IsConnectionFree" : false,
                         "WhoUseConnection": CurrentUser.shared.ID],merge: true) { error in
            if let err = error {
                print("Ошибка запиписи о сессии пользователя - \(err)")
            }
        }
    }
    
    func deleteConnectionStatus(serverName: String, userID: String){
        
        let userRef = db.collection("Servers").document(serverName).collection("Users").whereField("WhoUseConnection", isEqualTo:userID)
        
        userRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("Ошибка удаления сессии пользователя - \(error)")
            }
            guard let querySnapshot else {return}
            for document in querySnapshot.documents {
                let documentRef = document.reference
                documentRef.setData(["IsConnectionFree" : true,
                                      "WhoUseConnection": ""],merge: true) { error in
                    if let error = error {
                        print("Ошибка удаления сессии пользователя - \(error)")
                    }
                }
            }
        }
    }
}
