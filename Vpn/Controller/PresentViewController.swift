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
        
        print(Auth.auth().currentUser?.phoneNumber)
        
        User.shared.loadMetadata { [weak self]  in
            if Auth.auth().currentUser?.uid != nil {  /// Проверяем авторизован наш пользователь в приложении
                
                Task {
                    await self?.receiptValidation()
                    self?.performSegue(withIdentifier: "goToVpn", sender: self)
                }
            }
        }
    }
    
    
    @IBAction func resotorePressed(_ sender: UIButton) { /// Кнопка восстановления нажата
        Task {
            await receiptValidation()
            switch User.shared.subscriptionStatus {
            case.valid(expirationDate: _),.notBuy: self.performSegue(withIdentifier: "goToVpn", sender: self)
            default:break
            }
        }
    }
}

extension PresentViewController: SKRequestDelegate{
    
    private func receiptValidation() async {
        let dataSubsc = await User.shared.refreshReceipt()
        if dataSubsc { /// Если чека нету, то мы его обновим
            refrreshReceipt()
        }
    }
    
    private func refrreshReceipt(){ /// Функция которая обновляет чек, вызываем когда чека нету
        let request = SKReceiptRefreshRequest(receiptProperties: nil)
        request.delegate = self
        request.start() /// Отправляет запрос в Apple App Store. Результаты запроса отправляются делегату запроса.
    }
    
    
    private func requestDidFinish(_ request: SKRequest) async {
        if request is SKReceiptRefreshRequest { /// Если чек есть вызваем еще раз функцию проверки чека
            await receiptValidation()
        }
    }
    
}








