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

    @IBOutlet weak var checkCodeUiButton: UIButton!
    @IBOutlet weak var codeTextView: UITextView!
    
    var verifictaionID = String()
    var phoneNumber = String()
    private let db = Firestore.firestore()
    
    private let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkCodeUiButton.alpha = 0.2
        
        codeTextView.delegate = self
    }

    
    @IBAction func checkCodePressed(_ sender: UIButton) {
        
        guard let code = codeTextView.text else {return} /// Если не можем получить то выходим из метода
        
        let credentional = PhoneAuthProvider.provider().credential(withVerificationID: verifictaionID, verificationCode: code)
        
        
        Auth.auth().signIn(with: credentional) { dataResult, error in
            
            if let err = error {
                
                let ac = UIAlertController(title: err.localizedDescription, message: nil, preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Отмена", style: .cancel)
                ac.addAction(cancel)
                self.present(ac, animated: true)
                print("Ошибка регистрации - \(err)")
                
            }else {
                self.performSegue(withIdentifier: "checkCodeToVpn", sender: self)
            }
        }
        
    }
    

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let dvc = segue.destination as! HomeViewController
        
        dvc.currentUser = User(dataFirstLaunch: 0, subscriptionStatus: false, freeUser: true)
        dvc.phoneNumber = phoneNumber
        defaults.set(false, forKey: "subscriptionPayment")
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
            checkCodeUiButton.alpha = 1
            checkCodeUiButton.isEnabled = true /// Логическое значение, указывающее, находится ли элемент управления во включенном состоянии
        }else {
            checkCodeUiButton.alpha = 0.2
            checkCodeUiButton.isEnabled = false
        }
    }

        
    }
