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
    var currentUser: Users?
    var currentDevice = UIDevice.current.identifierForVendor!.uuidString /// Получаем текущий индефикатор устройства
    let db = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let current = defaults.string(forKey: "CurrentDevice") {
            if current == currentDevice {
                self.performSegue(withIdentifier: "goToVPN", sender: self)
            }
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let destination = segue.destination as? ViewController else {return}
        destination.currentUser = currentUser
    }
    
    
    
    @IBAction func subscriptionClick(_ sender: UIButton) {
        
    }
    
    
    @IBAction func freeVersionClick(_ sender: UIButton) {
        
        db.collection("Users").document(currentDevice).setData(["dataFirstLaunch":NSDate().timeIntervalSince1970,"firstLaunch": true,"subscription":false])
        defaults.set(self.currentDevice, forKey: "CurrentDevice")
        currentUser = Users(dataFirstLaunch: NSDate().timeIntervalSince1970, firstLaunch: true, subscription: false)
        performSegue(withIdentifier: "freeVersionToVPN", sender: self)
    }
    
    
    @IBAction func autorizationPressed(_ sender: UIButton) {
    }
    
    
    
}



