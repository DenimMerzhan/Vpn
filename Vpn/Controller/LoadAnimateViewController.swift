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
    let statusText = "Идет загрузка информации о пользователе...".map({String($0)})
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.navigationBar.isHidden = true
        setupAnimation()
        textAnimation()
        SKRequest().delegate = self
        
        User.shared.loadMetadata { [weak self]  in
            
            User.shared.refreshReceipt { [weak self] needToUpdateReceipt in
                if needToUpdateReceipt {
                    self?.refrreshReceipt()
                    User.shared.refreshReceipt { needToUpdateReceipt in
                        self?.performSegue(withIdentifier: "animateToHomeController", sender: self)
                    }
                    return
                }
                self?.performSegue(withIdentifier: "animateToHomeController", sender: self)
            }
        }
    }
    
    //MARK: - Анимация загрузки
    
    func setupAnimation(){
        
        animation.loopMode = .loop
        animation.frame = CGRect(x: 0, y: 0, width: 700, height: 700)
        animation.contentMode = .scaleAspectFill
        animation.center = view.center
        animation.play()
        
        statusLoadLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 200)
        statusLoadLabel.font = .systemFont(ofSize: 10)
        statusLoadLabel.textColor = .white
        statusLoadLabel.textAlignment = .center
        statusLoadLabel.numberOfLines = 2
        statusLoadLabel.lineBreakMode = .byWordWrapping
        statusLoadLabel.center.x = animation.frame.width / 2
        statusLoadLabel.center.y = animation.frame.height / 2
        animation.addSubview(statusLoadLabel)
        
        view.addSubview(animation)
        
        
    }
    //MARK: -  Анимация текста
    
    func textAnimation(){
        
        statusLoadLabel.text = ""
        var i = 0
        let statusText = self.statusText
        let statusLoadLabel = self.statusLoadLabel
        
       Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if i >= statusText.count {
                timer.invalidate()
                return
            }
           statusLoadLabel.text = statusLoadLabel.text! +  statusText[i]
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
