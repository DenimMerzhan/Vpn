//
//  ViewController.swift
//  Vpn
//
//  Created by Деним Мержан on 28.03.23.
//

import UIKit
import ChameleonFramework
import AVVPNService

class ViewController: UIViewController {
    
    var pressedVPNButton: Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    
    
    
    @IBAction func vpnConnectPressed(_ sender: UIButton) {
        pressedVPNButton = !pressedVPNButton
        
        if pressedVPNButton {
            
            let credentials = AVVPNCredentials.IPSec(server: "62.84.98.66", username: "vpnuser", password: "FEdJF89frXxLr9kE", shared: "fbfe64e2359a248448a771c044758a39")
            
            AVVPNService.shared.connect(credentials: credentials) { (err:Error?) in
                
            }
            
        }else {
            AVVPNService.shared.disconnect()
        }
        
        
        


    }
    
}
    
    
