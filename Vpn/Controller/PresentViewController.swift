//
//  PresentViewController.swift
//  Vpn
//
//  Created by Деним Мержан on 28.03.23.
//

import UIKit

class PresentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    

    @IBAction func registerClick(_ sender: UIButton) {
        
        
    }
    
    
    @IBAction func subscriptionClick(_ sender: UIButton) {
        performSegue(withIdentifier: "goToVPN", sender: self)
        
    }
    
}
