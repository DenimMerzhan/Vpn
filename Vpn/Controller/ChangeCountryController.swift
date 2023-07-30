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
    
    var countryNames = [String]()
    let db = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        
        searchBar.searchTextField.backgroundColor = UIColor(named: K.color.placeholder) /// Настраиваем строку поиска
        searchBar.placeholder = "Поиск"
        searchBar.searchTextField.textColor = .white
        searchBar.backgroundImage = UIImage()
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage() /// Убираем полоску
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true /// большой НавБар
        }
        loadCountry()
        
    }
    
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return countryNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath)
        cell.textLabel?.text = countryNames[indexPath.row]
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        tableView.rowHeight = 60
        
        if countryNames[indexPath.row] == User.shared.selectedCountry?.name {
            cell.accessoryType = .checkmark
        }else {cell.accessoryType = .none}
                
        return cell
    }
    
    

    //MARK: - Пользователь выбрал ячейку
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { /// Выбрав ячейку мы сохраняем данные для входа на сервер в UserDefaults
        
        let selectedCountryName = countryNames[indexPath.row]
        User.shared.selectedCountry = Country(name: selectedCountryName)
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


//MARK: - Загрузка названий стран

extension ChangeCountryController { /// Загружаем данные для подключения к впн с сервера и записывем в массив стран
    
    func loadCountry() {
        
        db.collection("Country").getDocuments { querySnapshot, err in
            
            if let error = err {print("Ошибка загрузки названия стран - \(error)")}
            guard querySnapshot != nil else {return}
            
            for document in querySnapshot!.documents {
                let data = document.data()
                if let nameCountry = data["name"] as? String {
                    self.countryNames.append(nameCountry)
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
}
