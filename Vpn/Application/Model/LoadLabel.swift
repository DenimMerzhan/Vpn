//
//  LoadLabel.swift
//  Vpn
//
//  Created by Деним Мержан on 31.07.23.
//

import UIKit

class LoadLabel: UILabel {

    var timer: Timer?
    
    func createTextAnimate(textToAdd: String){
        
        let textArr = textToAdd.map({String($0)})
        self.text = ""
        var i = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            if i >= textArr.count {
                timer.invalidate()
                return
            }
            guard let textLabel = self?.text else {return}
           self?.text = textLabel +  textArr[i]
           i += 1
        }
    }
    
}
