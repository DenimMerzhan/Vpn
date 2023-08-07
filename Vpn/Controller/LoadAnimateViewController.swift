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
        loadUserData()
        
        
    }
    //MARK: -  Загрузка данных о пользователе
    
    func loadUserData(){
        
        User.shared.loadMetadata { [weak self] success  in
            
            if success { /// Если данные загрузились успешно то пытаемся загрузить квитанцию
                User.shared.getReceipt {
                    self?.performSegue(withIdentifier: "animateToHomeController", sender: self)
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

