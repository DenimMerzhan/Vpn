//
//  ChangeCountryController.swift
//  Vpn
//
//  Created by Деним Мержан on 31.03.23.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

class ChangeCountryController: UITableViewController {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    lazy var loadIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.frame.size = CGSize(width: 100, height: 100)
        indicator.color = .white
        indicator.center = view.center
        indicator.startAnimating()
        return indicator
    }()
    
    var countryArr = [Country]()
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage() /// Убираем полоску
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true /// большой НавБар
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ChangeCountryNetworkService.loadAllCountry { [weak self] countryArr in
            
            self?.countryArr = countryArr
            self?.loadIndicator.stopAnimating()
            self?.tableView.reloadData()
        }
        
        searchBar.searchTextField.backgroundColor = UIColor(named: K.color.placeholder) /// Настраиваем строку поиска
        searchBar.placeholder = "Поиск"
        searchBar.searchTextField.textColor = .white
        searchBar.backgroundImage = UIImage()
        
        view.addSubview(loadIndicator)
    }
    
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return countryArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath)
        cell.textLabel?.text = countryArr[indexPath.row].name
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        tableView.rowHeight = 60
        
        if countryArr[indexPath.row].name == CurrentUser.shared.selectedCountry?.name {
            cell.accessoryType = .checkmark
        }else {cell.accessoryType = .none}
                
        return cell
    }
    
    

    //MARK: - Пользователь выбрал ячейку
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let country = countryArr[indexPath.row]
        CurrentUser.shared.selectedCountry = country
        
        if CurrentUser.shared.ID == "test" {
            ChangeCountryNetworkService.writeLastSelectedCountryOnUserDefault(nameCountry: country.name)
        }else {
            ChangeCountryNetworkService.writeLastSelectedCountryOnServer(nameCountry: country.name, userID: CurrentUser.shared.ID)
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
