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
        
        receiptValidation()
        defaults.set("dwd", forKey: "CurrentDevice")
        
        if let current = defaults.string(forKey: "CurrentDevice") {
            if current == currentDevice {
                self.performSegue(withIdentifier: "goToVPN", sender: self)
            }
        }
        
        SKPaymentQueue.default().add(self) /// Добавляем наблюдателя за транзакциями
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let destination = segue.destination as? ViewController else {return}
        destination.currentUser = currentUser
    }
    
    
    
    @IBAction func subscriptionClick(_ sender: UIButton) {
        
        buyPremium()
    }
    
    
    @IBAction func freeVersionClick(_ sender: UIButton) {
        
        db.collection("Users").document(currentDevice).setData(["dataFirstLaunch":NSDate().timeIntervalSince1970,"firstLaunch": true,"subscription":false])
        defaults.set(self.currentDevice, forKey: "CurrentDevice")
        currentUser = Users(dataFirstLaunch: NSDate().timeIntervalSince1970, firstLaunch: true, subscription: false)
        performSegue(withIdentifier: "freeVersionToVPN", sender: self)
    }
    
    
    @IBAction func autorizationPressed(_ sender: UIButton) {
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
                print("Transaction Okay")

                
                SKPaymentQueue.default().finishTransaction(transaction) /// Завершаем транзакцию
                
            }else if transaction.transactionState == .failed {
                print("Transaction  Fall")
                
                if  let error = transaction.error {
                    print("Ошибка обработки платежа - \(error.localizedDescription)")
                }
                
                SKPaymentQueue.default().finishTransaction(transaction)
                
            }else if transaction.transactionState == .restored {
                print("Transaction Restored")
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



