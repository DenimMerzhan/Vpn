//
//  RegisterViewController.swift
//  Vpn
//
//  Created by Деним Мержан on 09.04.23.
//

import UIKit

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    

    
    @IBOutlet weak var getNumberLabel: UIButton!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var numberCountryPicker: UIPickerView!
    
    var valideNumber: Bool? {
        
        didSet {
            if valideNumber != nil {
                
                if valideNumber! {
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
        
        
        let previousResponder = phoneNumberTextField.superview
        let previousTextField = previousResponder as!  CustomTextField

        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: phoneNumberTextField, queue: OperationQueue.main) { (notification) in /// Добавляем наблюдателя который следит за изменениями в ТекстФилде
            
            let count = self.phoneNumberTextField.text?.count
            
            if count == 3 {
                self.phoneNumberTextField.text = self.phoneNumberTextField.text! + " "
            }else if count == 7 {
                self.phoneNumberTextField.text = self.phoneNumberTextField.text! + " "
            }else if count == 10 {
                self.phoneNumberTextField.text = self.phoneNumberTextField.text! + " "
            }
            
            if count == 13 {
                self.valideNumber = true
            }else {
                self.valideNumber = false
            }
                }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        phoneNumberTextField.attributedPlaceholder = NSAttributedString(string: "981 755 00 00", attributes: [NSAttributedString.Key
            .foregroundColor: UIColor.white.withAlphaComponent(0.2),
            .font:UIFont.systemFont(ofSize: 20)])
        
        phoneNumberTextField.textColor = .white
        phoneNumberTextField.font = .systemFont(ofSize: 20)
        
        numberCountryPicker.delegate = self
        phoneNumberTextField.delegate = self
        
        getNumberLabel.backgroundColor = UIColor(named: "ColorButtonYellow")?.withAlphaComponent(0.1) /// Устанавливаем кнопку полупрозрачной
        getNumberLabel.tintColor = UIColor(named: "ColorButtonYellow")?.withAlphaComponent(0.1)
        
    }
    
    
    
    @IBAction func getCodePressed(_ sender: UIButton) {
        
        
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


extension RegisterViewController {
    
    func spaceNumber() {
        
        
        
    }
    
}
