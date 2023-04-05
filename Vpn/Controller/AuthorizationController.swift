//
//  RegistrationControllerViewController.swift
//  Vpn
//
//  Created by Деним Мержан on 31.03.23.
//

import UIKit
import FirebaseAuth

class AuthorizationCotroller: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var label = UILabel()
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        emailTextField.layer.cornerRadius = 30.00
        passwordTextField.layer.cornerRadius = 30.00
    }
    
    
    @IBAction func authPressed(_ sender: UIButton) {
        
        if let email = emailTextField.text, let password = passwordTextField.text{ /// Если строки логина и пароля не пустые то записываем значения
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in /// В функцию Auth передаются данные о логине и пароле которые ввел пользователь
                if let er = error { /// Данные об ошибке которые передаются в функцию createErorr
                    
                    self.label.removeFromSuperview()
                    self.label = self.creatEror(erorr: er.localizedDescription)
                    self.view.addSubview(self.label)
                    
                    
                }else{
                    self.performSegue(withIdentifier: "authToChat", sender: self) /// Если все прошло успешно переходим на экран чата
                }
            }
        }
        
    }
    
    
    
    func creatEror(erorr: String) -> UILabel {  /// Функция которая создает Label указанных размеров и заполняет ее данными об ошибке
        let lb1 = UILabel(frame: CGRect(x:0, y:30, width:380, height:130))
        lb1.text = erorr
        lb1.textAlignment = .center  /// Выравнивание текста
        lb1.font = UIFont.systemFont(ofSize: 15)
        lb1.textColor = .red
        lb1.lineBreakMode = .byWordWrapping  /// Лейбл будет расширяться в зависимости от количества текста
        lb1.numberOfLines = 3  /// Ограничения для расширения 3 строки
        return lb1
    }
    

}
