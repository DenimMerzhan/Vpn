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
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    
    var phoneNumber: String?
    var verfictationID: String!
    var listController = FPNCountryListViewController(style: .grouped)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadIndicator.isHidden = true
        
        fetchCode.alpha = 0.2
        fetchCode.isEnabled = false
        
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
        loadIndicator.isHidden = false
        loadIndicator.startAnimating()
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber!, uiDelegate: nil) { [weak self] verivicationId, error in
            if let err = error {
                print("Ошибка авторизации - \(err.localizedDescription.description)")
                if let alert = self?.createAlert(errorText: err.localizedDescription.description) {
                    self?.present(alert, animated: true)
                }
            }
            else {
                guard verivicationId != nil else {return}
                self?.verfictationID = verivicationId!
                self?.performSegue(withIdentifier: "authToCheckCode", sender: self)
                self?.loadIndicator.stopAnimating()
                self?.loadIndicator.isHidden = true
                
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
            phoneNumber = textField.getFormattedPhoneNumber(format: .E164)
        }else {
            fetchCode.alpha = 0.2
            fetchCode.isEnabled = false
        }
        
    }
    
    func fpnDisplayCountryList() {
        let navigationController = UINavigationController(rootViewController: listController)
        listController.title = "Страны"
        phoneNumberTextField.text = ""
        self.present(navigationController, animated: true)
    }
    
}

//MARK: - CreateAlert

extension RegisterViewController {
    func createAlert(errorText: String) -> UIAlertController {
        let ac = UIAlertController(title: "Произошла ошибка - \(errorText)", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Отмена", style: .cancel) { action in
            DispatchQueue.main.async { [weak self] in
                self?.dismiss(animated: true)
            }
        }
        ac.addAction(cancel)
        return ac
    }
}



