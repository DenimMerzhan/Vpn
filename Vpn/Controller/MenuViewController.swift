//
//  MenuViewController.swift
//  Vpn
//
//  Created by Деним Мержан on 05.04.23.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDataSource {

    

    @IBOutlet weak var tableView: UITableView!
    
    var menuCell = ["Поддержка","Ответы на вопросы", "Пользовательское соглашение","Политика конфиденциальности"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self /// Устанавливаем себя в качестве делегата

        // Do any additional setup after loading the view.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Yeha")
        return menuCell.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
        cell.textLabel?.text = menuCell[indexPath.row]
        cell.textLabel?.textColor = .white
        return cell
    }
    
    
    @IBAction func regristerPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "preferencesToAuth", sender: self)
    }
    
    
    
}
