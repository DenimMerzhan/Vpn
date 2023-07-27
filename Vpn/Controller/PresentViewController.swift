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

    private let defaults = UserDefaults.standard
    private let productID  = "com.TopVpnDenimMerzhan.Vpn"
    
    var activeSubscripeAbsence = false
    
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
        User.shared.loadMetadata {
            if Auth.auth().currentUser?.uid != nil { /// Проверяем авторизован наш пользователь в приложении
                self.performSegue(withIdentifier: "goToVpn", sender: self)
            }else {
                Task {
                    await receiptValidation()
                    switch User.shared.subscriptionStatus {
                    case.valid(expirationDate: _),.ended: self.performSegue(withIdentifier: "goToVpn", sender: self)
                    default:createAlert(text: "Нет активных подписок", buttonText: "ок")
                    }
                }
                SKPaymentQueue.default().add(self)
            }
        }
    }
    
    
    @IBAction func subscriptionClick(_ sender: UIButton) { /// Кнопка подписки нажата
        buyPremium()
    }
    
    @IBAction func resotorePressed(_ sender: UIButton) { /// Кнопка восстановления нажата
        Task {
            await receiptValidation()
            switch User.shared.subscriptionStatus {
            case.valid(expirationDate: _),.notBuy: self.performSegue(withIdentifier: "goToVpn", sender: self)
            default:createAlert(text: "Нет активных подписок", buttonText: "отмена")
            }
        }
    }
    
//MARK: - Подготовка перед переходом
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is HomeViewController {
            SKPaymentQueue.default().remove(self) /// Удаляем себя в качестве наблюдателя во избежании повторных вызовов функций
        }
    }
}


//MARK: - Платная подпиская

extension PresentViewController: SKPaymentTransactionObserver {
    
    func buyPremium(){
        
        if SKPaymentQueue.canMakePayments() { /// Если включен родительский контроль то покупку совершить нельзя
            
            let paymentRequest = SKMutablePayment() /// Создаем запрос на покупку в приложение
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
            
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            
        
            if transaction.transactionState == .purchased {
                
                SKPaymentQueue.default().finishTransaction(transaction) /// Завершаем транзакцию
                        
                print("Transaction  Okay")
                self.defaults.set(true, forKey: "subscriptionPayment")
                createAlert(text: "Премиум аккаунт активирован", buttonText: "ок")
                self.performSegue(withIdentifier: "goToVpn", sender: self)
                
                
            }else if transaction.transactionState == .failed {
                if  let error = transaction.error {
                    print("Ошибка обработки платежа - \(error.localizedDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .restored {
                SKPaymentQueue.default().finishTransaction(transaction)
            }
            else if transaction.transactionState == .purchasing {
                print("Обработка платежа")
            }
        }
    }
    

}

extension PresentViewController {
    func createAlert(text: String,buttonText: String){
        let ac = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: buttonText, style: .cancel)
        ac.addAction(cancel)
        self.present(ac, animated: true)
    }
    
}

extension PresentViewController: SKRequestDelegate{
    
    private func receiptValidation() async {
        
            
            let dataSubsc = await User.shared.receiptValidation()
            if let expirationDate = dataSubsc.date { /// Если дата была не нулевой
                
                if Date() > expirationDate { /// Если текущая дата больше даты окончания заканчиваем подписку
                    User.shared.subscriptionStatus = .ended
                    print("Now \(expirationDate)")
                }
                
                else {
                    User.shared.subscriptionStatus = .valid(expirationDate: expirationDate)
                    print("Yeah \(expirationDate)")
                }
            }
            
            else if dataSubsc.refresh { /// Если чека нету, то мы его обновим
                refrreshReceipt()
            }
            
            else { /// latest_receipt_info - если данной строки нет значит пользователь никогда не покупал подписку, в таком случае откланяем viewController
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let dvc = storyboard.instantiateViewController(withIdentifier: "presentVC") as! PresentViewController
                User.shared.subscriptionStatus = .notBuy
                dvc.activeSubscripeAbsence = true
                self.present(dvc, animated: true)
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








