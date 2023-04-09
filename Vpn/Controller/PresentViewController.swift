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
        
        
        if let firstLainch  = defaults.object(forKey: "FirstLaunch") { /// Если есть ключ FirstLaunch то проверяем его
            
            if firstLainch as! Bool == false { /// Если это не первый вход то переходим на второй контроллер
                changeRootVC() /// Устанавливаем новый контроллер корневым и показываем его
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
        
        
        defaults.set(false, forKey: "subscriptionPayment")
        
        
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
                
                changeRootVC()
                
                
                
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


//MARK: - Установка корневого контроллера


extension PresentViewController {
    
    func changeRootVC(){
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "VpnID") as! ViewController
        UIApplication.shared.windows.first?.rootViewController = viewController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
        
//
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let dvc = storyboard.instantiateViewController(withIdentifier: "VpnID") as! ViewController
//        self.present(dvc, animated: true)
    }
    
}



