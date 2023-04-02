//
//  RegistrationControllerViewController.swift
//  Vpn
//
//  Created by Деним Мержан on 31.03.23.
//

import UIKit
import FirebaseAuth

class RegistrationController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.layer.cornerRadius = 30.00
        passwordTextField.layer.cornerRadius = 30.00
    }
    
    
    @IBAction func registerPressed(_ sender: UIButton) {
        
            if let email = emailTextField.text, let password = passwordTextField.text {  /// если пользователь что то ввел в емаил и пароль то пытаемся создать нового пользователя
                
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in  /// В случае неудачи нам вернутся данные об ошибке, если все прошло усешно то перейдем на экран чата
                    if let er = error {
                        self.creatEror(erorr: er.localizedDescription) /// Вызывает функцию creatErorr
                    }else {
                        self.performSegue(withIdentifier:"registerToChat" , sender: self)
                    }
                }
            }
        
    }
    
    
    func creatEror(erorr: String){  /// Функция которая создает Label указанных размеров и заполняет ее данными об ошибке
        let lb1 = UILabel()
        let stack = UIStackView() /// Создали StackView
        lb1.text = erorr
        lb1.textAlignment = .center  /// Выравнивание текста
        lb1.font = UIFont.systemFont(ofSize: 15)
        lb1.textColor = .red
        lb1.lineBreakMode = .byWordWrapping  /// Лейбл будет расширяться в зависимости от количества текста
        lb1.numberOfLines = 3  /// Ограничения для расширения 3 строки
        stack.addArrangedSubview(lb1)
        stack.axis = .vertical  /// Выравнивание StackView
        navigationItem.titleView = stack /// Отображает StackView
    }
    

}
