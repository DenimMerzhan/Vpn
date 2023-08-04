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
    var statusLoad = LoadLabel()
    var reauthorizationTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.navigationBar.isHidden = true
        setupAnimation()
        statusLoad.createTextAnimate(textToAdd: "Идет загрузка информации о пользователе...")
        SKRequest().delegate = self
        loadUserData()
        
        
    }
    //MARK: -  Загрузка данных о пользователе
    
    func loadUserData(){
        
        User.shared.loadMetadata { [weak self] success  in
            
            if success { /// Если данные загрузились успешно то пытаемся загрузить квитанцию
                User.shared.getReceipt { needToUpdateReceipt in
                    if needToUpdateReceipt { /// Если чека нет то обновляем его
                        self?.refrreshReceipt()
                        return
                    }
                    DispatchQueue.main.async {
                        self?.performSegue(withIdentifier: "animateToHomeController", sender: self)
                    }
                }
            }else { /// Если нет пишем о том что должно быть подключение к интернету и повторяем действие
                
                if self?.statusLoad.timer?.isValid == false {
                    self?.statusLoad.createTextAnimate(textToAdd: "Требуется подключение к интернету")
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
        
        statusLoad.frame = CGRect(x: 0, y: 0, width: view.frame.width / 2, height: 200)
        statusLoad.font = .systemFont(ofSize: 10)
        statusLoad.textColor = .white
        statusLoad.textAlignment = .center
        statusLoad.numberOfLines = 3
        statusLoad.lineBreakMode = .byWordWrapping
        statusLoad.center.x = animation.frame.width / 2
        statusLoad.center.y = animation.frame.height / 2
        animation.addSubview(statusLoad)
        
        view.addSubview(animation)
        
        
    }
}

//MARK: - Обновление чека

extension LoadAnimateViewController: SKRequestDelegate{
    
    private func refrreshReceipt(){ /// Функция которая обновляет чек, вызываем когда чека нету
        let request = SKReceiptRefreshRequest(receiptProperties: nil)
        request.delegate = self
        request.start() /// Отправляет запрос в Apple App Store. Результаты запроса отправляются делегату запроса.
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.refrreshReceipt()
        }
    }
    
    private func requestDidFinish(_ request: SKRequest) async { /// Сообщает делегату, что запрос выполнен.
        print("Oh")
        if request is SKReceiptRefreshRequest { /// Если чек есть вызваем еще раз функцию проверки чека
            User.shared.getReceipt { [weak self] needToUpdateReceipt in
                DispatchQueue.main.async {
                    self?.performSegue(withIdentifier: "animateToHomeController", sender: self)
                }
            }
        }
    }
}
