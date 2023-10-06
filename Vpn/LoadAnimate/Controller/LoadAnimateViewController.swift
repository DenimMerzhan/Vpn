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
    
    private var animation = LottieAnimationView(name: "animation_lkp59xl7")
    private var statusLoad = LoadLabel()
    private var reauthorizationTimer: Timer?
    private let loadAnimateNetworkService = LoadAnimateNetworkService()
    private let loadAnimateModel = LoadAnimateModel()
    private let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.navigationBar.isHidden = true
        
        setupAnimation()
        statusLoad.createTextAnimate(textToAdd: "Идет загрузка информации о пользователе...")
        loadUserData()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let lastSelectedServer = userDefault.value(forKey: "LastSelectedServer") as? String {
            HomeNetworkService().deleteConnectionStatus(serverName: lastSelectedServer,userID: CurrentUser.shared.ID)
            CurrentUser.shared.selectedServerName = lastSelectedServer
        }
    }
    
    //MARK: -  Загрузка данных о пользователе
    
    func loadUserData(){
        
        loadAnimateNetworkService.loadDateFirstLaunch { [weak self] result in
            
            switch result {
            case .success(let dateFirstLaunch):
                self?.loadAnimateModel.updateUserTrialStatus(dateFirstLaunch: dateFirstLaunch)
                self?.getReceipt()
            case .failure(let error):
                switch error {
                case .noInternetConnection:
                    self?.statusLoad.createTextAnimate(textToAdd: "Требуется подключение к интернету")
                    self?.loadUserData()
                case .dateFirstLaunchMissing:
                    self?.statusLoad.createTextAnimate(textToAdd: "Не удалось найти дату первой регистрации")
                }
            }
        }
    }
    
    func getReceipt(){
        
        MenuNetworkService.getReceipt { [weak self] result  in
            
            switch result {
            case .success(let dateEndSubscription):
                if dateEndSubscription < Date(){
                    CurrentUser.shared.subscriptionStatus = .ended
                }else {
                    CurrentUser.shared.subscriptionStatus = .valid(expirationDate: dateEndSubscription)
                }
            default: break
            }
            
            self?.performSegue(withIdentifier: "animateToHomeController", sender: self)
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

