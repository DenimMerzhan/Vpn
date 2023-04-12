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

    

    let defaults = UserDefaults.standard
    var currentUser: Users?
    var currentDevice = UIDevice.current.identifierForVendor!.uuidString /// Получаем текущий индефикатор устройства
    
    var segueId = Int()
    let db = Firestore.firestore()
    let productID  = "com.TopVpnDenimMerzhan.Vpn"
    
    var activeSubscripeAbsence = false
    var premiumSubscripe = false
    
    override func viewWillAppear(_ animated: Bool) {
        
        if activeSubscripeAbsence { /// Если не было активных подписок
            
            let ac = UIAlertController(title: "Нет активных подписок", message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Отмена", style: .cancel)
            ac.addAction(cancel)
            self.present(ac, animated: true)
            
        }

        
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "Назад", style: .plain, target: nil, action: nil) /// Текст кнопки назад
            
        
            DispatchQueue.main.async {
                
                if Auth.auth().currentUser?.uid != nil { /// Проверяем авторизован наш пользователь в приложении
                    
                    self.segueId = 1
                    self.performSegue(withIdentifier: "goToVpn", sender: self)
                    
                }
                
                else if let premium = self.defaults.object(forKey: "subscriptionPayment") as? Bool { /// Проверяем покупал ли подписку
                    
                    if premium  {
                        
                        self.segueId = 2
                        self.performSegue(withIdentifier: "goToVpn", sender: self)
                    }
                    
                }

            }
        
    }
    
    override var traitCollection: UITraitCollection { /// Меняем тему приложения на всегда светлый
      UITraitCollection(traitsFrom: [super.traitCollection, UITraitCollection(userInterfaceStyle: .light)])
    }
        
    
    override func viewDidLoad() {
        SKPaymentQueue.default().add(self)
    }
    
    
    @IBAction func subscriptionClick(_ sender: UIButton) { /// Кнопка подписки нажата
        buyPremium()
    }
    
    
    @IBAction func resotorePressed(_ sender: UIButton) { /// Кнопка восстановления нажата
        self.segueId = 3
        self.performSegue(withIdentifier: "goToVpn", sender: self)
    }
    
//MARK: - Подготовка перед переходом
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? ViewController {
            
            SKPaymentQueue.default().remove(self) /// Удаляем себя в качестве наблюдателя во избежании повторных вызовов функций
            
            if segueId == 1 {
                dvc.currentUser = Users(dataFirstLaunch: 0, subscriptionStatus: false, freeUser: true)
                dvc.phoneNumber = Auth.auth().currentUser!.phoneNumber!
            }else if segueId == 2 {
                dvc.currentUser = Users(dataFirstLaunch: 0, subscriptionStatus: true, freeUser: false)
            }else {
                dvc.currentUser = Users(dataFirstLaunch: 0, subscriptionStatus: false, freeUser: false)
            }
            
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
                        
                
                self.segueId = 2
                self.performSegue(withIdentifier: "goToVpn", sender: self)
                
                
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
    

}





//MARK: - Расширение для преобразования даты

extension Formatter {
    
    
    static let customDate: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") /// На каком языке будет отображться
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV" /// Какой формат M - месяц Y - Year b т.д
        
        return formatter
    }()
    
    static let formatToRusDate: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM"
        formatter.locale = Locale(identifier: "ru_Ru")
        
        return formatter
    }()
}







