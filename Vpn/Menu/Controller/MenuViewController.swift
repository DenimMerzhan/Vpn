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
    
    
    @IBOutlet weak var lowerStackView: UIStackView!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var premiumButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var heightTableViewConstrains: NSLayoutConstraint!
    @IBOutlet weak var loadStackView: UIStackView!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusLoad: LoadLabel!
    
    private let productID  = "com.TopVpnDenimMerzhan.Vpn1"
    private var menuCategories = [MenuCategory]()
    var delegate: MenuControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startSetup()
    }
    
    override func viewWillLayoutSubviews() {
        heightTableViewConstrains.constant = tableView.contentSize.height
    }
    
    
    @IBAction func restorePressedPurchases(_ sender: UIButton) {
        refreshReceipt()
        lowerStackView.isHidden = true
        loadStackView.isHidden = false
        loadIndicator.startAnimating()
        statusLoad.createTextAnimate(textToAdd: "Идет подготовка к восстановлению")
    }
    
    
    //MARK: -  Выход из аккаунта
    
    @IBAction func logOutPressed(_ sender: UIButton) {
        if Auth.auth().currentUser?.uid != nil {
            do {
                try Auth.auth().signOut()
                AVVPNService.shared.disconnect()
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let dvc = storyboard.instantiateViewController(withIdentifier: "presentVC") as?  PresentViewController else {return}
                self.present(dvc, animated: true)
                
            }catch {
                print("Ошибка выхода из учетной записи - \(error)")
            }
        }
    }
    
    
    @IBAction func buyPremiumPressed(_ sender: UIButton) {
        buyPremium()
        lowerStackView.isHidden = true
        loadStackView.isHidden = false
        loadIndicator.startAnimating()
        statusLoad.createTextAnimate(textToAdd: "Идет подготовка к покупке")
    }
    
}



extension MenuViewController {
    func startSetup(){
        
        menuCategories =  MenuModel.fillMenuCategory(menuCategory: menuCategories, phoneNumber: Auth.auth().currentUser?.phoneNumber)
        
        SKPaymentQueue.default().add(self)
        
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
        tableView.register(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: "MenuCell")
        
        switch CurrentUser.shared.subscriptionStatus {
        case.valid(expirationDate: _): premiumButton.setTitle("Подписка активирована", for: .normal)
            premiumButton.isUserInteractionEnabled = false
        case .ended: premiumButton.setTitle("Продлить подписку", for: .normal)
        default:break
        }
        premiumButton.sizeToFit()
    }
    
    func restoreVCForDefault(){
        isModalInPresentation = false
        loadIndicator.stopAnimating()
        loadStackView.isHidden = true
        lowerStackView.isHidden = false
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
        cell.isSelected = isSelected
        cell.menuCategory = menuCategories[indexPath.row]
        
        if case .privacyPolicy = menuCategories[indexPath.row].name {
            cell.tapGesture.addTarget(self, action: #selector(privacyPolicyPressed))
        }
        
        cell.dropMenuText.text = menuCategories[indexPath.row].description
        cell.dropMenuText.sizeToFit()
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
        switch menuCategories[indexPath.row].name {
        case .termsOfUse(name: _): if menuCategories[indexPath.row].isSelected {return 200}
        default: if menuCategories[indexPath.row].isSelected {return 150}
        }
        return 50
    }
    
    @objc func privacyPolicyPressed(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PrivacyPolicyVC")
        self.present(vc, animated: true)
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
                
                MenuNetworkService.getReceipt { [weak self] isMissingReceipt ,dateEndSubscription in
                    
                    guard let dateEndSubscription = dateEndSubscription else {return}
                    if Date() > dateEndSubscription {
                        CurrentUser.shared.subscriptionStatus = .ended
                    }else {
                        CurrentUser.shared.subscriptionStatus = .valid(expirationDate: dateEndSubscription)
                    }
                    
                    self?.restoreVCForDefault()
                    self?.delegate?.userBuyPremium()
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


//MARK:  - Запрос чека от Apple при восстановление покупок

extension MenuViewController: SKRequestDelegate {
    
    func refreshReceipt(){
        /// Функция которая обновляет чек, вызываем когда чека нету
        let request = SKReceiptRefreshRequest(receiptProperties: nil)
        request.delegate = self
        request.start() /// Отправляет запрос в Apple App Store. Результаты запроса отправляются делегату запроса.
        
    }
    
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print(error.localizedDescription)
        premiumButton.isUserInteractionEnabled = true
        restoreVCForDefault()
    }
    
    func requestDidFinish(_ request: SKRequest) {
        if request is SKReceiptRefreshRequest {
            
            if statusLoad.timer?.isValid == false {
                statusLoad.createTextAnimate(textToAdd: "Идет настройка аккаунта")
            }
            
            MenuNetworkService.getReceipt { [weak self] isMissingReceipt,dateEndSubscription in
                
                guard let dateEndSubscription = dateEndSubscription else {return}
                if dateEndSubscription < Date(){
                    CurrentUser.shared.subscriptionStatus = .ended
                    self?.premiumButton.setTitle("Продлить подписку", for: .normal)
                }else {
                    CurrentUser.shared.subscriptionStatus = .valid(expirationDate: dateEndSubscription)
                    self?.premiumButton.setTitle("Подписка активирована", for: .normal)
                }
                
                self?.premiumButton.sizeToFit()
                self?.restoreVCForDefault()
                self?.delegate?.userBuyPremium()
                AVVPNService.shared.disconnect()
            }
        }
    }
    
}
