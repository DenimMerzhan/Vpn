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


protocol MenuControllerDelegate {
    func userBuyPremium()
}

class MenuViewController: UIViewController, UITableViewDataSource {
    
    
    
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var premiumButton: UIButton!
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var loadStackView: UIStackView!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusLoad: LoadLabel!
    
    let productID  = "com.TopVpnDenimMerzhan.Vpn"
    var menuCell = ["Поддержка","Ответы на вопросы", "Пользовательское соглашение","Политика конфиденциальности"]
    var delegate: MenuControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SKPaymentQueue.default().add(self)
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        switch User.shared.subscriptionStatus {
        case.valid(expirationDate: _): premiumButton.setTitle("Премиум активирован", for: .normal)
        default:break
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        SKPaymentQueue.default().remove(self)
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
        
        logOutButton.isHidden = true
        loadStackView.isHidden = false
        loadIndicator.startAnimating()
        statusLoad.createTextAnimate(textToAdd: "Идет подготовка к покупке")
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
            self.isModalInPresentation = true /// не даем пользователю закрыть контроллер
            
        }
        
    }
    
    //MARK: -  Отслеживание транзакции
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            
            if transaction.transactionState == .purchased {
                
                print("Транзакция прошла")
                SKPaymentQueue.default().finishTransaction(transaction)
                premiumButton.titleLabel?.text = "Премиум активирован"
                if statusLoad.timer?.isValid == false {
                    statusLoad.createTextAnimate(textToAdd: "Идет настройка аккаунта")
                }
                User.shared.refreshReceipt { [weak self] needToUpdateReceipt in
                    DispatchQueue.main.async {
                        self?.isModalInPresentation = false
                        self?.loadIndicator.stopAnimating()
                        self?.loadStackView.isHidden = true
                        self?.logOutButton.isHidden = false
                        self?.delegate?.userBuyPremium()
                    }
                }
                AVVPNService.shared.disconnect()
            }
            
            else if transaction.transactionState == .failed {
                print("Failed")
                self.isModalInPresentation = false
                SKPaymentQueue.default().finishTransaction(transaction)
            }
            
            else if transaction.transactionState == .restored {
                print("Restored")
                self.isModalInPresentation = false
                SKPaymentQueue.default().finishTransaction(transaction)
                
            }
            
            else if transaction.transactionState == .purchasing {
                print("Обработка платежа")
                
            }
        }
    }
}





    

