//
//  AnimateViewController.swift
//  Vpn
//
//  Created by Деним Мержан on 30.07.23.
//

import UIKit
import Lottie
import StoreKit

class LoadAnimateViewController: UIViewController {
    
    var animation = LottieAnimationView(name: "animation_lkp59xl7")
    var statusLoadLabel = UILabel()
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.navigationBar.isHidden = true
        setupAnimation()
        textAnimation(textToAdd: "Идет загрузка информации о пользователе...")
        SKRequest().delegate = self
        loadUserData()
        
        
    }
    //MARK: -  Загрузка данных о пользователе
    
    func loadUserData(){
        
        User.shared.loadMetadata { [weak self] success in
            
            if success { /// Если данные загрузились успешно то пытаемся загрузить квитанцию
                User.shared.refreshReceipt { needToUpdateReceipt in
                    if needToUpdateReceipt {
                        self?.refrreshReceipt()
                        self?.loadUserData()
                        return
                    }
                    self?.performSegue(withIdentifier: "animateToHomeController", sender: self)
                }
            }else { /// Если нет пишем о том что должно быть подключение к интернету и повторяем действие
                
                if let timer = self?.timer {
                    if timer.isValid == false {
                        self?.textAnimation(textToAdd: "Требуется подключение к интернету")
                    }
                }
                self?.loadUserData()
            }
        }
    }
    
}


//MARK: - Анимация загрузки

extension LoadAnimateViewController {

    func setupAnimation(){
        
        animation.loopMode = .loop
        animation.frame = view.bounds
        animation.contentMode = .scaleAspectFill
        animation.center = view.center
        animation.play()
        
        statusLoadLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width / 2, height: 200)
        statusLoadLabel.font = .systemFont(ofSize: 10)
        statusLoadLabel.textColor = .white
        statusLoadLabel.textAlignment = .center
        statusLoadLabel.numberOfLines = 3
        statusLoadLabel.lineBreakMode = .byWordWrapping
        statusLoadLabel.center.x = animation.frame.width / 2
        statusLoadLabel.center.y = animation.frame.height / 2
        animation.addSubview(statusLoadLabel)
        
        view.addSubview(animation)
        
        
    }
    //MARK: -  Анимация текста
    
    func textAnimation(textToAdd: String){
        
        let textArr = textToAdd.map({String($0)})
        statusLoadLabel.text = ""
        var i = 0
        let statusLoadLabel = self.statusLoadLabel
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if i >= textArr.count {
                timer.invalidate()
                return
            }
           statusLoadLabel.text = statusLoadLabel.text! +  textArr[i]
           i += 1
        }
    }
}


//MARK: - Обновление чека

extension LoadAnimateViewController: SKRequestDelegate{
    
    private func refrreshReceipt(){ /// Функция которая обновляет чек, вызываем когда чека нету
        let request = SKReceiptRefreshRequest(receiptProperties: nil)
        request.delegate = self
        request.start() /// Отправляет запрос в Apple App Store. Результаты запроса отправляются делегату запроса.
    }
    
    
    private func requestDidFinish(_ request: SKRequest) async {
        if request is SKReceiptRefreshRequest { /// Если чек есть вызваем еще раз функцию проверки чека
            
            User.shared.refreshReceipt { [weak self] needToUpdateReceipt in
                if needToUpdateReceipt {self?.refrreshReceipt()}
            }
        }
    }
}
