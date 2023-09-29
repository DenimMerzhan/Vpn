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
    private var lastSelectedCountry: Country?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.navigationBar.isHidden = true
        
        setupAnimation()
        statusLoad.createTextAnimate(textToAdd: "Идет загрузка информации о пользователе...")
        loadUserData()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let homeVC = segue.destination as? HomeViewController else {return}
        homeVC.country = lastSelectedCountry
    }
    
    //MARK: -  Загрузка данных о пользователе
    
    func loadUserData(){
        
        loadAnimateNetworkService.loadDateFirstLaunch { [weak self] isConntectToInternet, dateFirstLaunch in
            
            if isConntectToInternet == false {
                self?.statusLoad.createTextAnimate(textToAdd: "Требуется подключение к интернету")
                self?.loadUserData()
                return
            }
            
            if let dateFirstLaunch = dateFirstLaunch {
                self?.loadAnimateModel.updateUserTrialStatus(dateFirstLaunch: dateFirstLaunch)
            }
            
            if let lastSelectedCountryName = self?.userDefault.value(forKey: "LastSelectedCountry") as? String {
                self?.loadAnimateNetworkService.loadCountry(name: lastSelectedCountryName) { country in
                    self?.lastSelectedCountry = country
                    self?.getReceipt()
                }
            }else {
                self?.getReceipt()
            }
        }
    }
    
    func getReceipt(){
        
        MenuNetworkService.getReceipt { [weak self] isMissingReceipt,dateEndSubscription  in
            
            if isMissingReceipt {
                self?.performSegue(withIdentifier: "animateToHomeController", sender: self)
                return
            }
            
            guard let dateEndSubscription = dateEndSubscription else {return}
            if dateEndSubscription < Date(){
                CurrentUser.shared.subscriptionStatus = .ended
            }else {
                CurrentUser.shared.subscriptionStatus = .valid(expirationDate: dateEndSubscription)
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

