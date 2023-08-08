//
//  CustomCell.swift
//  test
//
//  Created by Деним Мержан on 03.08.23.
//

import UIKit

class MenuCell: UITableViewCell {

    
    @IBOutlet weak var nameCategory: UILabel!
    @IBOutlet weak var dropMenu: UIView!
    @IBOutlet weak var descriptionCell: UILabel!
    
    var tapGesture = UITapGestureRecognizer()
    var arrow = UIImageView()
    
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

