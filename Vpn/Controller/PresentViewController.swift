//
//  PresentViewController.swift
//  Vpn
//
//  Created by Деним Мержан on 28.03.23.
//

import UIKit
import FirebaseFirestore
import StoreKit
import FirebaseAuth


class PresentViewController: UIViewController {

    
    
    @IBOutlet weak var buttonStackView: UIStackView!
    
    private let productID  = "com.TopVpnDenimMerzhan.Vpn"
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "Назад", style: .plain, target: nil, action: nil) /// Текст кнопки назад
    }
    
    override var traitCollection: UITraitCollection { /// Меняем тему приложения на всегда светлый
        UITraitCollection(traitsFrom: [super.traitCollection, UITraitCollection(userInterfaceStyle: .light)])
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        User.shared.ID = "+79817550000"
        
        if Auth.auth().currentUser?.uid != nil { /// Проверяем авторизован наш пользователь в приложении
            startAnimating()
            User.shared.loadMetadata { [weak self]  in
                
                User.shared.refreshReceipt { [weak self] needToUpdateReceipt in
                    if needToUpdateReceipt {self?.refrreshReceipt()}
                }
                self?.performSegue(withIdentifier: "goToVpn", sender: self)
            }
        }
    }
    
    
    @IBAction func resotorePressed(_ sender: UIButton) { /// Кнопка восстановления нажата
        
        User.shared.refreshReceipt { [weak self] needToUpdateReceipt in
            if needToUpdateReceipt {self?.refrreshReceipt()}
            
            switch User.shared.subscriptionStatus {
            case.valid(expirationDate: _),.notBuy: self?.performSegue(withIdentifier: "goToVpn", sender: self)
            default:break
            }
        }
        
    }
}


//MARK: - Обновление чека

extension PresentViewController: SKRequestDelegate{
    
    private func refrreshReceipt(){ /// Функция которая обновляет чек, вызываем когда чека нету
        let request = SKReceiptRefreshRequest(receiptProperties: nil)
        request.delegate = self
        request.start() /// Отправляет запрос в Apple App Store. Результаты запроса отправляются делегату запроса.
    }
    
    
    private func requestDidFinish(_ request: SKRequest) async {
        if request is SKReceiptRefreshRequest { /// Если чек есть вызваем еще раз функцию проверки чека
            
            User.shared.refreshReceipt { [weak self] needToUpdateReceipt in
                if needToUpdateReceipt {self?.refrreshReceipt()}
            }
        }
    }
}

//MARK: -  Запуск анимации при загрузке данных о пользователе

extension PresentViewController {
    
    func startAnimating(){
        buttonStackView.isHidden = true
    }
    
}








