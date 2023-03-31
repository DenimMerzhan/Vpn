//
//  ChangeCountryController.swift
//  Vpn
//
//  Created by Деним Мержан on 31.03.23.
//

import UIKit

class ChangeCountryController: UITableViewController {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage() /// Убираем полоску
        navigationController?.navigationBar.barStyle = .black
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true /// большой НавБар
        }
        
        searchBar.backgroundColor = UIColor(named: K.color.background )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }



}
