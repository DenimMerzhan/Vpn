//
//  CustomCell.swift
//  test
//
//  Created by Деним Мержан on 03.08.23.
//

import UIKit

//protocol MenuCellDelegate: AnyObject {
//    func privacyPolicyPressed()
//}

class MenuCell: UITableViewCell {

    
    @IBOutlet weak var nameCategory: UILabel!
    @IBOutlet weak var dropMenu: UIView!
    @IBOutlet weak var dropMenuText: UILabel!
    
    var tapGesture = UITapGestureRecognizer()
    var arrow = UIImageView()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                arrow.image = UIImage(named: "ArrowUp")?.withTintColor(.white, renderingMode: .alwaysOriginal)
                dropMenu.isHidden = false
            }else {
                arrow.image = UIImage(named: "ArrowDown")?.withTintColor(.white, renderingMode: .alwaysOriginal)
                dropMenu.isHidden = true
            }
        }
    }
    
    var menuCategory: MenuCategory? {
        didSet {
            guard menuCategory != nil else {return}
            switch menuCategory!.name {
            case .support(name: let name), .askQuestion(name: let name),.termsOfUse(name: let name), .accountInfo(name: let name):
                nameCategory.text = name
            case .privacyPolicy(name: let name):
                nameCategory.text = name
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.frame.size.width = UIScreen.main.bounds.width
        self.frame.size.height = 50
        
        let image = UIImage(named: "ArrowDown")?.withTintColor(.white).withRenderingMode(.alwaysOriginal)
        arrow.image = image
        arrow.frame = CGRect(x: frame.width - 66, y: 0, width: 15, height: 15)
        arrow.center.y = frame.height / 2
        arrow.contentMode = .scaleAspectFit
        arrow.clipsToBounds = true
        
        dropMenu.addGestureRecognizer(tapGesture)
        
        self.addSubview(arrow)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

