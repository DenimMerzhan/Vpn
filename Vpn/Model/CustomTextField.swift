//
//  CustomTextField.swift
//  Vpn
//
//  Created by Деним Мержан on 10.04.23.
//

import UIKit

protocol DeleteButtonPressed {
    
    func deleteButtonPressed(pressed: Bool)
    
}

class CustomTextField: UITextField {

    var deleteButtonDelegate: DeleteButtonPressed?
    
    override func deleteBackward() {
        deleteButtonDelegate?.deleteButtonPressed(pressed: true)
        
        super.deleteBackward()
        
    }

}


