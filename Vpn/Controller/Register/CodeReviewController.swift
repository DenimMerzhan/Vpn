//
//  CheckCodViewController.swift
//  Vpn
//
//  Created by Деним Мержан on 10.04.23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CodeReviewController: UIViewController {

    @IBOutlet weak var checkCodeButton: UIButton!
    @IBOutlet weak var codeTextView: UITextView!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var resendCode: UIButton!
    @IBOutlet weak var timerToResend: UILabel!
    @IBOutlet weak var loadStackView: UIStackView!
    
    var verifictaionID = String()
    var phoneNumber: String!
    
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startTimer()
        codeTextView.delegate = self
        loadIndicator.isHidden = true
        
    }

    
    @IBAction func checkCodePressed(_ sender: UIButton) {
        
        guard let code = codeTextView.text else {return} /// Если не можем получить то выходим из метода
        
        let credentional = PhoneAuthProvider.provider().credential(withVerificationID: verifictaionID, verificationCode: code)
        loadIndicator.isHidden = false
        loadIndicator.startAnimating()
        codeTextView.endEditing(true)
        checkCodeButton.isEnabled = false
        
        Auth.auth().signIn(with: credentional) { [weak self] dataResult, error in
            
            if let err = error {
                
                let ac = UIAlertController(title: err.localizedDescription, message: nil, preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Отмена", style: .cancel)
                ac.addAction(cancel)
                self?.present(ac, animated: true)
                print("Ошибка регистрации - \(err)")
                
            }else {
                guard let phoneNumber = self?.phoneNumber else {return}
                User.shared.ID = phoneNumber
                self?.db.collection("Users").document(phoneNumber).setData(["dateActivationTrial" : Date().timeIntervalSince1970,
                    "ID": phoneNumber],completion: { err in
                    if let error = err {
                        print("Ошибка создания нового пользователя - \(error)")
                    }else {self?.performSegue(withIdentifier: "authToAnimate", sender: self)}
                })
            }
        }
        
    }
    
    
    @IBAction func resendCodePressed(_ sender: UIButton) {
        
        startTimer()
        codeTextView.endEditing(true)
        codeTextView.text = ""
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber!, uiDelegate: nil) { verivicationId, error in
            if let err = error {
                print("Ошибка авторизации - \(err)")
            }
        }
    }
}


extension CodeReviewController {
    
    func startTimer(){
        
        resendCode.titleLabel?.alpha = 0.2
        resendCode.isEnabled = false
        timerToResend.isHidden = false
        var i = 10
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            self?.timerToResend.text = String(i)
            i -= 1
            if i < 0 {
                self?.resendCode.isEnabled = true
                self?.timerToResend.isHidden = true
                timer.invalidate()
            }
        }
    }
}



//MARK: - UITextViewDelegate

extension CodeReviewController: UITextViewDelegate {
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool { /// Ограничение по количеству символов
        
        let currentCharacterCount = codeTextView.text.count
        
                if range.length + range.location > currentCharacterCount {
                    return false
                }
        let newLenght = currentCharacterCount + text.count  - range.length
        return newLenght <= 6
            }
    
    
    
    func textViewDidChange(_ textView: UITextView) { /// Когда текст был изменен
        if codeTextView.text.count == 6 {
            checkCodeButton.alpha = 1
            checkCodeButton.isEnabled = true /// Логическое значение, указывающее, находится ли элемент управления во включенном состоянии
        }else {
            checkCodeButton.alpha = 0.2
            checkCodeButton.isEnabled = false
        }
    }

    }
