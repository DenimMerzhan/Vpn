//
//  PresentViewController.swift
//  Vpn
//
//  Created by Деним Мержан on 28.03.23.
//

import UIKit
import FirebaseFirestore
import StoreKit
import FirebaseAuth


class PresentViewController: UIViewController {
    
    @IBOutlet weak var buttonStackView: UIStackView!
    
    private let userDefaults = UserDefaults.standard
    private let productID  = "com.TopVpnDenimMerzhan.Vpn"
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "Назад", style: .plain, target: nil, action: nil) /// Текст кнопки назад
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if Auth.auth().currentUser?.uid != nil { /// Проверяем авторизован наш пользователь в приложении
            guard let phoneNumber = Auth.auth().currentUser!.phoneNumber else {return}
            CurrentUser.shared.ID =  phoneNumber
            performSegue(withIdentifier: "goToAnimate", sender: self)
        }
    }
    
    @IBAction func testingPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeController = storyboard.instantiateViewController(withIdentifier: "HomeController") as! HomeViewController
        let dateForTesting = Date(timeIntervalSince1970: Date().timeIntervalSince1970 + 205000)
        CurrentUser.shared.freeUserStatus = .valid(expirationDate: dateForTesting)
        CurrentUser.shared.ID = "test"
        
        if let name = userDefaults.value(forKey: "LastSelectedCountry") as? String {
            let loadNetworkService =  LoadAnimateNetworkService()
            loadNetworkService.loadCountry(name: name) { country in
                CurrentUser.shared.selectedCountry = country
            }
        }
        
        navigationController?.pushViewController(homeController, animated: true)
    }
}











