//
//  PresentViewController.swift
//  Vpn
//
//  Created by Деним Мержан on 28.03.23.
//

import UIKit
import FirebaseFirestore
import StoreKit


class PresentViewController: UIViewController {

    

    let defaults = UserDefaults.standard
    var currentUser: Users?
    var currentDevice = UIDevice.current.identifierForVendor!.uuidString /// Получаем текущий индефикатор устройства
    
    let db = Firestore.firestore()
    let productID  = "com.TopVpnDenimMerzhan.Vpn"
    var arrProduct  = [SKProduct]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        
//        defaults.set(true, forKey: "FirstLaunch")
        
        if let firstLainch  = defaults.object(forKey: "FirstLaunch") { /// Если есть ключ FirstLaunch то проверяем его
            
            if firstLainch as! Bool == false { /// Если это не первый вход то переходим на второй контроллер
                self.performSegue(withIdentifier: "goToVPN", sender: self)
            }
        }
    
        
    }
    
    override func viewDidLoad() {
        SKPaymentQueue.default().add(self) /// Добавляем наблюдателя за транзакциями
    }
    
    
    @IBAction func subscriptionClick(_ sender: UIButton) {
        
        buyPremium()
    }
    
    
    @IBAction func freeVersionClick(_ sender: UIButton) {
        
        defaults.set(true, forKey: "FirstLaunch")
        
        db.collection("Users").document(currentDevice).setData(["dataFirstLaunch":NSDate().timeIntervalSince1970,"subscription":false]) /// Добавляем данные о бесплатно пользователе
        defaults.set(false, forKey: "subscriptionPayment")
        performSegue(withIdentifier: "goToVPN", sender: self)
    }
    
    
    
    @IBAction func resotorePressed(_ sender: UIButton) {
        
        defaults.set(true, forKey: "subscriptionPayment")
        defaults.set(true, forKey: "FirstLaunch")
        performSegue(withIdentifier: "goToVPN", sender: self)
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
                
                print("Transaction  Okay")
                
                defaults.set(true, forKey: "subscriptionPayment")
                defaults.set(true, forKey: "FirstLaunch")
                SKPaymentQueue.default().finishTransaction(transaction) /// Завершаем транзакцию
                
                performSegue(withIdentifier: "goToVPN", sender: self)
                
                
                
            }else if transaction.transactionState == .failed {
                print("Transaction  Fall")
                
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
    
    
//MARK: - Проверка квитанции

}


extension Formatter {
    
    
    static let customDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
        return formatter
    }()
}



