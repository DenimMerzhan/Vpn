//
//  ChangeCountryController.swift
//  Vpn
//
//  Created by Деним Мержан on 31.03.23.
//

import UIKit

class ChangeCountryController: UITableViewController {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var country = ["Россия","Амстердам"]
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        searchBar.searchTextField.backgroundColor = UIColor(named: K.color.placeholder)
        searchBar.placeholder = "Поиск"
        searchBar.searchTextField.textColor = .white
        searchBar.backgroundImage = UIImage()
        
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage() /// Убираем полоску
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationItem.backBarButtonItem =   UIBarButtonItem(
            title: "Назад", style: .plain, target: nil, action: nil)
        navigationController?.navigationItem.backButtonTitle = "dwdwwd"
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true /// большой НавБар
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return country.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath)
        cell.textLabel?.text = country[indexPath.row]
        cell.backgroundColor = UIColor(named: K.color.background)
        cell.textLabel?.textColor = .white
        tableView.rowHeight = 60
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    


}
