//
//  HomeNetworkService.swift
//  Vpn
//
//  Created by Деним Мержан on 28.09.23.
//

import Foundation
import FirebaseFirestore

protocol HomeNetworkServiceProtocol: AnyObject {
    func loadServerWithError(error: NetworkError)
}

enum NetworkError: Error {
    case noInternetConnection(String)
    case serverIsOverloaded(String)
    case errorFirebase(String)
    case noDocumentOnServer(String)
    case serverIpMissing(String)
    
    var errorDescripiton: String {
        switch self {
        case .errorFirebase(let description),.noInternetConnection(let description),.noDocumentOnServer(let description),.serverIpMissing(let description),.serverIsOverloaded(let description):
            return description
        }
    }
}

class HomeNetworkService {
    
    private let db = Firestore.firestore()
    weak var delegate: HomeNetworkServiceProtocol?
    
    init(){}
    
    func getServerData(serverName: String,completion: @escaping(Server) -> ()){
        
        let ref = db.collection("Servers").document(serverName).collection("Users").whereField("IsConnectionFree", isEqualTo: true).limit(to: 1)
        
        ref.getDocuments { [weak self] querySnapshot, error in
            
            if let error = error {
                self?.sendFailureToMain(error: .errorFirebase(error.localizedDescription))
            }
            
            if querySnapshot?.metadata.isFromCache == true {
                self?.sendFailureToMain(error: .noInternetConnection("Отсутсвует подключение к интернету"))
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
                self?.sendFailureToMain(error: .serverIsOverloaded("Cервер Перегружен"))
            }
            
        }
    }
    
    private func getServerIP(serverName: String,completion: @escaping(_ serverIP: String) -> ()){
        
        let serverRef = db.collection("Servers").document(serverName)
        
        serverRef.getDocument { [weak self] querySnapshot, error in
            if let error = error {
                self?.sendFailureToMain(error: .errorFirebase(error.localizedDescription))
            }
            
            if querySnapshot?.metadata.isFromCache == true {
                self?.sendFailureToMain(error: .noDocumentOnServer("Не удалось получить документ с сервера"))
                return
            }
            
            if let serverIP = querySnapshot?.data()?["ServerIP"] as? String {
                completion(serverIP)
            }else {
                self?.sendFailureToMain(error: .serverIpMissing("Отсутсвует IP сервера"))
            }
        }
    }
    
    private func sendFailureToMain(error: NetworkError){
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.loadServerWithError(error: error)
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
