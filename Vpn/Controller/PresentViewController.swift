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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        SKRequest().delegate = self
        
        if Auth.auth().currentUser?.uid != nil { /// Проверяем авторизован наш пользователь в приложении
            User.shared.ID =  Auth.auth().currentUser!.uid
            performSegue(withIdentifier: "goToAnimate", sender: self)
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









