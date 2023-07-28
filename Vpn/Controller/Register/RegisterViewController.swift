//
//  RegisterViewController.swift
//  Vpn
//
//  Created by Деним Мержан on 09.04.23.
//

import UIKit
import FirebaseAuth
import FlagPhoneNumber

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    

    @IBOutlet weak var getNumberLabel: UIButton!
    @IBOutlet weak var phoneNumberTextField: FPNTextField!
    
    private var registerAuthUser = ""
    private var verfictationID  = ""
    private var phoneNumber = ""
    
    private var deletePressed =  Bool()
    private var validNumberString = ""
    private var valideNumber = false {
        
        didSet {
            
            if valideNumber { /// Если номер валидный то делаем кнопку получить код доступной
                getNumberLabel.alpha = 1
                getNumberLabel.isEnabled = true
            }else {
                getNumberLabel.alpha = 0.2
                getNumberLabel.isEnabled = false
                }
                
                
        }
    }
    
    
//MARK: Проверка валидности номера
    
    
    override func viewWillAppear(_ animated: Bool) { // Проверяем валидность номера
    
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "Назад", style: .plain, target: nil, action: nil) /// Текст кнопки назад
    }
    
    
//MARK: -  Настройка пикера и текстфилда
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberTextField.delegate = self
        phoneNumberTextField.attributedPlaceholder = NSAttributedString(string: "926 254 02 98", attributes: [NSAttributedString.Key
            .foregroundColor: UIColor.white.withAlphaComponent(0.2),
            .font:UIFont.systemFont(ofSize: 20)]) /// Установиили стиль текст филд
        
        phoneNumberTextField.textColor = .white
        phoneNumberTextField.font = .systemFont(ofSize: 20)
        
        valideNumber = false
        
    }
    
    
    
    
    func deleteButtonPressed(pressed: Bool) { /// Функция которая указывает был ли нажат знак удаления на клавиатуре пользователя
        deletePressed = true
    }
    
    
    
    
    
//MARK: - Кнопка получить кода нажата
    
    
    
    @IBAction func getCodePressed(_ sender: UIButton) {
        
        
        if var number = phoneNumberTextField.text {

            let vowels: Set<Character> = ["-", " "]
            number.removeAll(where: {vowels.contains($0)}) /// Убираем лишние знаки из номера
            number = "+7" + number
            
                PhoneAuthProvider.provider().verifyPhoneNumber(number, uiDelegate: nil) { verivicationId, error in
                    if let err = error {
                        print("Ошибка авторизации - \(err)")
                    }
                    
                    else {
                        self.phoneNumber = number
                        self.verfictationID = verivicationId!
                        self.performSegue(withIdentifier: "authToCheckCode", sender: self)

                    }
                }


            
        }
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let dvc = segue.destination as? CodeReviewController else {return}
    
        dvc.phoneNumber = phoneNumber
        dvc.verifictaionID = verfictationID
    }
    
    
    

    //MARK: - PickerView
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: "+7", attributes: [NSAttributedString.Key
            .foregroundColor: UIColor.white,
            .font:UIFont.boldSystemFont(ofSize: 20)])
    }
    
    
    
}
    

// MARK: - TextField
    

extension RegisterViewController: UITextFieldDelegate {
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool { /// Когда пользователь нажал кнопку Go на клавиатуре
            phoneNumberTextField.endEditing(true)  /// Если кнопка нажата клавиатура пропадает и начинается поиск
            return true
        }
        

    }



