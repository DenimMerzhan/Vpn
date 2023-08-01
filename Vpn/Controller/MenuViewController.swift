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
    
    @IBOutlet weak var heightTableViewConstrains: NSLayoutConstraint!
    @IBOutlet weak var loadStackView: UIStackView!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusLoad: LoadLabel!
    
    let productID  = "com.TopVpnDenimMerzhan.Vpn"
    var menuCell = ["Поддержка","Ответы на вопросы", "Пользовательское соглашение","Политика конфиденциальности"]
    var delegate: MenuControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SKPaymentQueue.default().add(self)
        
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
        
        switch User.shared.subscriptionStatus {
        case.valid(expirationDate: _): premiumButton.setTitle("Подписка активирована", for: .normal)
            premiumButton.isUserInteractionEnabled = false
        case .ended: premiumButton.setTitle("Продлить подписку", for: .normal)
        default:break
        }
        premiumButton.sizeToFit()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        SKPaymentQueue.default().remove(self)
    }
    
    override func viewWillLayoutSubviews() {
        heightTableViewConstrains.constant = tableView.contentSize.height
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
    
    
    //MARK: -  Выход из аккаунта
    
    @IBAction func logOutPressed(_ sender: UIButton) {
        if Auth.auth().currentUser?.uid != nil {
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
    
    
    
    //MARK: - кнопка покупки нажата
    
    @IBAction func buyPremiumPressed(_ sender: UIButton) {
        buyPremium()
        
        logOutButton.isHidden = true
        loadStackView.isHidden = false
        loadIndicator.startAnimating()
        statusLoad.createTextAnimate(textToAdd: "Идет подготовка к покупке")
    }
    
}

//MARK: - Покупка премиум


extension MenuViewController: SKPaymentTransactionObserver {
    
    private func buyPremium(){
        
        if SKPaymentQueue.canMakePayments() { /// Если включен родительский контроль то покупку совершить нельзя
            
            let paymentRequest = SKMutablePayment() /// Создаем запрос на покупку в приложение
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
            premiumButton.isUserInteractionEnabled = false
            self.isModalInPresentation = true /// не даем пользователю закрыть контроллер
            
        }
        
    }
    
    //MARK: -  Отслеживание транзакции
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            
            if transaction.transactionState == .purchased {
                
                print("Транзакция прошла")
                
                SKPaymentQueue.default().finishTransaction(transaction)
                
                premiumButton.setTitle("Подписка активирована", for: .normal)
                premiumButton.sizeToFit()
                
                if statusLoad.timer?.isValid == false {
                    statusLoad.createTextAnimate(textToAdd: "Идет настройка аккаунта")
                }
                User.shared.refreshReceipt { [weak self] needToUpdateReceipt in
                    DispatchQueue.main.async {
                        self?.restoreVCForDefault()
                        self?.delegate?.userBuyPremium()
                    }
                }
                AVVPNService.shared.disconnect()
            }
            
            else if transaction.transactionState == .failed {
                print("Failed")
                premiumButton.isUserInteractionEnabled = true
                restoreVCForDefault()
                SKPaymentQueue.default().finishTransaction(transaction)
            }
            
            else if transaction.transactionState == .restored {
                print("Restored")
                premiumButton.isUserInteractionEnabled = true
                SKPaymentQueue.default().finishTransaction(transaction)
                
            }
            
            else if transaction.transactionState == .purchasing {
                print("Обработка платежа")
                
            }
        }
    }
}



extension MenuViewController {
    
    func restoreVCForDefault(){
        isModalInPresentation = false
        loadIndicator.stopAnimating()
        loadStackView.isHidden = true
        logOutButton.isHidden = false
    }
    
}


    

