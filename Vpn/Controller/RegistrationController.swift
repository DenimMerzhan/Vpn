//
//  RegistrationControllerViewController.swift
//  Vpn
//
//  Created by Деним Мержан on 31.03.23.
//

import UIKit

class RegistrationController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.layer.cornerRadius = 30.00
        passwordTextField.layer.cornerRadius = 30.00
    }
    

}
