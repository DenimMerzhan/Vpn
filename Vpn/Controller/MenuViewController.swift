//
//  MenuViewController.swift
//  Vpn
//
//  Created by Деним Мержан on 05.04.23.
//

import UIKit
import FirebaseAuth
import StoreKit
import AVVPNService

class MenuViewController: UIViewController, UITableViewDataSource {
    
    
    
    @IBOutlet weak var buttonPremium: UIButton!
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let productID  = "com.TopVpnDenimMerzhan.Vpn"
    var menuCell = ["Поддержка","Ответы на вопросы", "Пользовательское соглашение","Политика конфиденциальности"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SKPaymentQueue.default().add(self)
        tableView.dataSource = self
        
        switch User.shared.subscriptionStatus {
        case.valid(expirationDate: _),.ended: buttonPremium.isHidden = true
        default:break
        }
        
    }
    
    
    
    
    //MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuCell.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
        cell.textLabel?.text = menuCell[indexPath.row]
        cell.textLabel?.textColor = .white
        return cell
    }
    
    
    //MARK: -  Регистрация нажата
    
    @IBAction func regristerPressed(_ sender: UIButton) {
        
        if Auth.auth().currentUser?.uid != nil {
            logOut()
        }else {
            performSegue(withIdentifier: "menuToAuth", sender: self)
        }
        
    }
    
    
    
    
//MARK: - кнопка покупки нажата
    
    @IBAction func buyPremiumPressed(_ sender: UIButton) {
        buyPremium()
    }
    
}


 //MARK: - LogOut

extension MenuViewController {
    
    func logOut(){ /// Выходим из учетной записи и переходим на главный контроллер
        do {
            try Auth.auth().signOut()
            AVVPNService.shared.disconnect()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let dvc = storyboard.instantiateViewController(withIdentifier: "presentVC") as! PresentViewController
            self.present(dvc, animated: true)
            
        }catch {
            print("Ошибка выхода из учетной записи - \(error)")
        }
    }
    
}




//MARK: - Покупка премиум


extension MenuViewController: SKPaymentTransactionObserver {
    
    private func buyPremium(){
        
        if SKPaymentQueue.canMakePayments() { /// Если включен родительский контроль то покупку совершить нельзя
            
            let paymentRequest = SKMutablePayment() /// Создаем запрос на покупку в приложение
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
            
        }
        
    }
    
    
    
//MARK: -  Отслеживание транзакции
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            
            if transaction.transactionState == .purchased {
                
                if Auth.auth().currentUser?.uid != nil { ///Если пользователь авторизовна через номер телефона то выходим
                    try! Auth.auth().signOut()
                }
                print("Транзакция прошла")
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                Task {
                    User.shared.refreshReceipt(completion:)
                }
                AVVPNService.shared.disconnect()
            }
                
            else if transaction.transactionState == .failed {
                    print("Failed")
                    SKPaymentQueue.default().finishTransaction(transaction)
                    SKPaymentQueue.default().remove(self)
            }
            
            else if transaction.transactionState == .restored {
                print("Restored")
                SKPaymentQueue.default().finishTransaction(transaction)
                
            }
            
            else if transaction.transactionState == .purchasing {
                print("Обработка платежа")
                
            }
            
        }
        
        
    }
}
