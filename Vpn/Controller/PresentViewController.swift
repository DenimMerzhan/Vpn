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
        
        fetchAvailableProducts()
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

extension PresentViewController: SKPaymentTransactionObserver, SKProductsRequestDelegate {

    

    
    
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
    
    
    
    
    func receiptValidation(){
        let urlString = "https://sandbox.itunes.apple.com/verifyReceipt" /// Указываем что берем даныне с песочницы
        
        guard let receiptURL = Bundle.main.appStoreReceiptURL, let receiptString = try? Data(contentsOf: receiptURL).base64EncodedString() , let url = URL(string: urlString) else { /// 1 URL-адрес файла для квитанции App Store о пакете.   2  Преобразуем в строку    3 преобразуем наш URL песочницы в URL
                       return
               }
        
        let requestData : [String : Any] = ["receipt-data" : receiptString, /// Создаем словарь
                                                    "password" : "11f70af409dc42dfadee27090ff87b66", /// пароль это секретный ключ
                                                    "exclude-old-transactions" : false] /// Исключать старые транзакции нет
        let httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: []) /// Объект, который выполняет преобразование между JSON и эквивалентными объектами Foundation.
        
        var request = URLRequest(url: url) /// Запрос загрузки URL, который не зависит от протокола или схемы URL.
        request.httpMethod = "POST" /// POST — означает что некоторые данные должны быть помещены на сервер.
        
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type") /// Задает значение для поля заголовка. Field Имя поля заголовка для установки. В соответствии с HTTP RFC имена полей заголовков HTTP нечувствительны к регистру.
        
        request.httpBody = httpBody /// Данные, отправляемые в виде тела сообщения запроса, например, для HTTP-запроса POST.
        
        URLSession.shared.dataTask(with: request) { data, respose, error in
            
            DispatchQueue.main.async {
                if let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments){
                    print(jsonData)
              }
            }
            
        }.resume()
        
    }
    
    
    
    
    
    
//MARK: - Загружаем все продукты пользователя
    
    func fetchAvailableProducts(){
        
        let productIdentifiers = NSSet(object: productID)
        let productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if (response.products.count > 0) {
            
              arrProduct.removeAll()
            
              for prod in response.products
              {
                  print(prod)
                  arrProduct.append(prod)
              }
          }
    }
    
}



