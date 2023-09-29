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
    
}











