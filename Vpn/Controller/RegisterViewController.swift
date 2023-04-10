//
//  RegisterViewController.swift
//  Vpn
//
//  Created by Деним Мержан on 09.04.23.
//

import UIKit

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, DeleteButtonPressed {
    
    
    
    @IBOutlet weak var getNumberLabel: UIButton!
    @IBOutlet weak var phoneNumberTextField: CustomTextField!
    @IBOutlet weak var numberCountryPicker: UIPickerView!
    var deletePressed =  Bool()
    var validNumberString = ""
    var valideNumber: Bool? {
        
        didSet {
            if valideNumber != nil {
                
                if valideNumber! { /// Если номер валидный то делаем кнопку получить код доступной
                    getNumberLabel.backgroundColor = UIColor(named: "ColorButtonYellow")
                    getNumberLabel.tintColor = UIColor(named: "ColorButtonYellow")
                }else {
                    getNumberLabel.backgroundColor = UIColor(named: "ColorButtonYellow")?.withAlphaComponent(0.2)
                    getNumberLabel.tintColor = UIColor(named: "ColorButtonYellow")?.withAlphaComponent(0.2)
                }
                
                
            }
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: phoneNumberTextField, queue: OperationQueue.main) { (notification) in /// Добавляем наблюдателя который следит за изменениями в ТекстФилде
            
            let count = self.phoneNumberTextField.text!.count
            
            if count == 1 {
                self.deletePressed = false
            }
            
            if self.deletePressed == false {
                
                if count == 3 {
                    self.phoneNumberTextField.text = self.phoneNumberTextField.text! + " "
                }else if count == 7 {
                    self.phoneNumberTextField.text = self.phoneNumberTextField.text! + "-"
                }else if count == 10 {
                    self.phoneNumberTextField.text = self.phoneNumberTextField.text! + "-"
                }
            }else{
                self.deletePressed = false
            }
            
            
            
            if count == 13 {
                self.validNumberString = self.phoneNumberTextField.text!
                if self.phoneNumberTextField.text!.first == "9" {
                    self.valideNumber = true
                }
                
            }else if count > 13 {
                self.phoneNumberTextField.text = self.validNumberString
            }else {
                self.valideNumber = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberTextField.deleteButtonDelegate = self
        numberCountryPicker.delegate = self
        phoneNumberTextField.delegate = self
        
        phoneNumberTextField.attributedPlaceholder = NSAttributedString(string: "926 254 02 98", attributes: [NSAttributedString.Key
            .foregroundColor: UIColor.white.withAlphaComponent(0.2),
            .font:UIFont.systemFont(ofSize: 20)]) /// Установиили стиль текст филд
        
        phoneNumberTextField.textColor = .white
        phoneNumberTextField.font = .systemFont(ofSize: 20)
        
        
        
        getNumberLabel.backgroundColor = UIColor(named: "ColorButtonYellow")?.withAlphaComponent(0.1) /// Устанавливаем кнопку полупрозрачной
        getNumberLabel.tintColor = UIColor(named: "ColorButtonYellow")?.withAlphaComponent(0.1)
        
    }
    
    
    
    
    func deleteButtonPressed(pressed: Bool) { /// Функция которая указывает был ли нажат знак удаления на клавиатуре пользователя
        deletePressed = true
    }
    
    @IBAction func getCodePressed(_ sender: UIButton) {
        if let valid = valideNumber {
            if valid {
                performSegue(withIdentifier: "goToCod", sender: self)
            }
        }
        
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

