//
//  SceneDelegate.swift
//  Vpn
//
//  Created by Деним Мержан on 28.03.23.
//

import UIKit
import AVVPNService
import StoreKit


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) { /// Когда пользователь закрывает приложение мы меняем данные на фейковые что бы он не смог подключиться через меню настроек
        
        
        let currentQueue: SKPaymentQueue = SKPaymentQueue.default() /// Завершаем все транзакции что бы они не выполнялись снова
        for transaction in currentQueue.transactions {
            currentQueue.finishTransaction(transaction)
        }
        
        var credentials = AVVPNCredentials.IPSec(server: "0", username: "Fake", password: "Fake", shared: "Fake")
        AVVPNService.shared.disconnect()
        AVVPNService.shared.connect(credentials: credentials) { error in /// Производим подключение к выбранной стране
            if error != nil {
                print("Ошибка подключения: \(error!)")
            }
            
            print("sceneDidDisconnect")
        }
        
        func sceneDidBecomeActive(_ scene: UIScene) {
            // Called when the scene has moved from an inactive state to an active state.
            // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        }
        
        func sceneWillResignActive(_ scene: UIScene) {
            // Called when the scene will move from an active state to an inactive state.
            // This may occur due to temporary interruptions (ex. an incoming phone call).
        }
        
        func sceneWillEnterForeground(_ scene: UIScene) {
            // Called as the scene transitions from the background to the foreground.
            // Use this method to undo the changes made on entering the background.
        }
        
        func sceneDidEnterBackground(_ scene: UIScene) {
            // Called as the scene transitions from the foreground to the background.
            // Use this method to save data, release shared resources, and store enough scene-specific state information
            // to restore the scene back to its current state.
        }
        
        
    }
    
}
