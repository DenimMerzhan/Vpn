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
    let defaults = UserDefaults.standard
    
    var currentUsers = Users(dataFirstLaunch: 0, subscriptionStatus: false, freeUser: false)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SKPaymentQueue.default().add(self)
        tableView.dataSource = self /// Устанавливаем себя в качестве делегата
        
        if currentUsers.freeUser { /// Если пользователь уже залогинен то текст кнопки выйти из аккаунта
            accountButton.setTitle("Выйти из аккаунта", for: .normal)
        }else if currentUsers.subscriptionStatus { /// Если у пользователя текущий премиум активен то убираем кнопку купить перимум
            buttonPremium.isHidden = true
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
    
    func buyPremium(){
        
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
                
            
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let dvc = storyboard.instantiateViewController(withIdentifier: "VpnID") as! ViewController
                dvc.currentUser = Users(dataFirstLaunch: 0, subscriptionStatus: true, freeUser: false)
                
                AVVPNService.shared.disconnect()
                
                SKPaymentQueue.default().remove(self)
                SKPaymentQueue.default().finishTransaction(transaction)
                self.present(dvc, animated: true)
            }
                
            else if transaction.transactionState == .failed {
                    SKPaymentQueue.default().finishTransaction(transaction)
                    SKPaymentQueue.default().remove(self)
            }
            
            else if transaction.transactionState == .purchased {
                print("Обработка платежа")
                
            }
            
        }
        
        
    }
}
