//
//  RegisterViewController.swift
//  Vpn
//
//  Created by Деним Мержан on 09.04.23.
//

import UIKit
import FirebaseAuth
import FlagPhoneNumber

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var fetchCode: UIButton!
    @IBOutlet weak var phoneNumberTextField: FPNTextField!
    
    var phoneNumber: String?
    var verfictationID: String!
    var listController = FPNCountryListViewController(style: .grouped)

    
    
    override func viewWillAppear(_ animated: Bool) { // Проверяем валидность номера
        
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "Назад", style: .plain, target: nil, action: nil) /// Текст кнопки назад
    }
    
    
    //MARK: -  Настройка пикера и текстфилда
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberTextField.setFlag(countryCode: .RU)
        phoneNumberTextField.delegate = self
        phoneNumberTextField.attributedPlaceholder = NSAttributedString(string: " 926 254 02 98", attributes: [NSAttributedString.Key
            .foregroundColor: UIColor.white.withAlphaComponent(0.2),
            .font:UIFont.systemFont(ofSize: 20)]) /// Установиили стиль текст филд
        
        phoneNumberTextField.textColor = .white
        phoneNumberTextField.font = .systemFont(ofSize: 20)
        phoneNumberTextField.displayMode = .list
        
        listController.setup(repository: phoneNumberTextField.countryRepository)
        listController.didSelect = { [weak self] county in
            self?.phoneNumberTextField.setFlag(countryCode: county.code)
        }
        
    }
    
    
    @IBAction func tapOnScreen(_ sender: UITapGestureRecognizer) {
        phoneNumberTextField.endEditing(true)
    }
    
    @IBAction func fetchCodeTapped(_ sender: UIButton) {
        guard phoneNumber != nil else {return}
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber!, uiDelegate: nil) { verivicationId, error in
            if let err = error {
                print("Ошибка авторизации - \(err)")
            }
            else {
                guard verivicationId != nil else {return}
                self.verfictationID = verivicationId!
                self.performSegue(withIdentifier: "authToCheckCode", sender: self)
                
            }
        }

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let dvc = segue.destination as? CodeReviewController else {return}
        guard phoneNumber != nil else {return}
        dvc.phoneNumber = phoneNumber!
        dvc.verifictaionID = verfictationID
    }
}


// MARK: - FPNTextFieldDelegate


extension RegisterViewController: FPNTextFieldDelegate {
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        ///
    }
    
    func fpnDidValidatePhoneNumber(textField: FlagPhoneNumber.FPNTextField, isValid: Bool) {
        if isValid {
            fetchCode.alpha = 1
            fetchCode.isEnabled = true
            phoneNumber = textField.getFormattedPhoneNumber(format: .International)
        }else {
            fetchCode.alpha = 0.2
            fetchCode.isEnabled = true
        }
    }
    
    func fpnDisplayCountryList() {
        let navigationController = UINavigationController(rootViewController: listController)
        listController.title = "Страны"
        phoneNumberTextField.text = ""
        self.present(navigationController, animated: true)
    }
    
}



