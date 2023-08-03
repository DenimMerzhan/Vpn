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

class MenuViewController: UIViewController {
    
    
    
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var premiumButton: UIButton!
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var heightTableViewConstrains: NSLayoutConstraint!
    @IBOutlet weak var loadStackView: UIStackView!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusLoad: LoadLabel!
    
    let productID  = "com.TopVpnDenimMerzhan.Vpn"
    var menuCategories = [MenuCategory]()
    var delegate: MenuControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startSetup()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        SKPaymentQueue.default().remove(self)
    }
    
    override func viewWillLayoutSubviews() {
        heightTableViewConstrains.constant = tableView.contentSize.height
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



//MARK: - TableView

extension MenuViewController: UITableViewDataSource,UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        
        let isSelected = menuCategories[indexPath.row].isSelected
        
        if isSelected {
            cell.arrow.image = UIImage(named: "ArrowUp")?.withTintColor(.white, renderingMode: .alwaysOriginal)
            cell.dropMenu.isHidden = false
        }else {
            cell.arrow.image = UIImage(named: "ArrowDown")?.withTintColor(.white, renderingMode: .alwaysOriginal)
            cell.dropMenu.isHidden = true
        }
        
        cell.descriptionCell.text = menuCategories[indexPath.row].description
        cell.nameCategory.text = menuCategories[indexPath.row].name
        cell.descriptionCell.sizeToFit()
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        menuCategories[indexPath.row].isSelected = !menuCategories[indexPath.row].isSelected
        
        for i in 0...menuCategories.count - 1 {
            if i == indexPath.row {continue}
            menuCategories[i].isSelected = false
        }
        tableView.reloadData()
        tableView.layoutIfNeeded()
        self.heightTableViewConstrains.constant = self.tableView.contentSize.height
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if menuCategories[indexPath.row].isSelected {return 150}
        return 50
    }
    
}


extension MenuViewController {
    func startSetup(){
        
        menuCategories.append(MenuCategory(name: "Поддержка",description: "Для поддержки пишите к нам на почту torVPNgmail.com"))
        menuCategories.append(MenuCategory(name: "Ответы на вопросы",description: "Все вопросы вы можете задать на нашу почту torVPNgmail.com"))
        menuCategories.append(MenuCategory(name: "Пользовательское соглашение",description: "Данное пользовательское соглашение можно скачать по ссылке"))
        menuCategories.append(MenuCategory(name: "Политика конфиденциальности",description: "Политика конфиденциальности..."))
        
        SKPaymentQueue.default().add(self)
        
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
        tableView.register(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: "MenuCell")
        
        switch User.shared.subscriptionStatus {
        case.valid(expirationDate: _): premiumButton.setTitle("Подписка активирована", for: .normal)
            premiumButton.isUserInteractionEnabled = false
        case .ended: premiumButton.setTitle("Продлить подписку", for: .normal)
        default:break
        }
        premiumButton.sizeToFit()
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
                User.shared.getReceipt { [weak self] needToUpdateReceipt in
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




