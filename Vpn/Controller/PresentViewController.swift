//
//  PresentViewController.swift
//  Vpn
//
//  Created by Деним Мержан on 28.03.23.
//

import UIKit
import FirebaseFirestore


class PresentViewController: UIViewController {

    let defaults = UserDefaults.standard
    let db = Firestore.firestore()
    var currentUser: Users?
    var currentDevice = UIDevice.current.identifierForVendor!.uuidString /// Получаем текущий индефикатор устройства
    
    
    override func viewWillAppear(_ animated: Bool) {
         loadData()
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let destination = segue.destination as? ViewController else {return}
        destination.currentUser = currentUser
    }
    
    
    
    @IBAction func subscriptionClick(_ sender: UIButton) {
        
    }
    
    
    @IBAction func freeVersionClick(_ sender: UIButton) {
        
        db.collection("Users").document(currentDevice).setData(["dataFirstLaunch":NSDate().timeIntervalSince1970,"firstLaunch": true,"subscription":false])
        
        currentUser = Users(dataFirstLaunch: NSDate().timeIntervalSince1970, firstLaunch: true, subscription: false)
        performSegue(withIdentifier: "freeVersionToVPN", sender: self)
    }
    
    
    @IBAction func autorizationPressed(_ sender: UIButton) {
    }
    
    
    
}


extension PresentViewController {
    
    func loadData() {
        
        db.collection("Users").getDocuments { QuerySnapshot, Error in
            if let err = Error {
                print("Ошибка получения данных - \(err)")
            }
            
            for document in QuerySnapshot!.documents {
                if document.documentID == self.currentDevice { /// Если текущий пользователь уже был зарегестрирован то переходим на главный экран
                    
                   let date =  document["dataFirstLaunch"] as! TimeInterval /// Преобразуем данные из FireBase
                   let subscription = document["subscription"] as! Bool
                   self.currentUser = Users(dataFirstLaunch: date, firstLaunch: false, subscription: subscription)
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "goToVPN", sender: self)
                    }
                    
                }
            }
        }
    }
}
