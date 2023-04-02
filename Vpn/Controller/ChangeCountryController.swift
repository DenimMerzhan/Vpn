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
    
    var country = [Country]()
    var currentIndexCountry = Int()
    let db = Firestore.firestore()
    var delegate: transtitonDataServer?
    
    
    
    
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
        loadCountry()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return country.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath)
        cell.textLabel?.text = country[indexPath.row].name
        cell.backgroundColor = UIColor(named: K.color.background)
        cell.textLabel?.textColor = .white
        tableView.rowHeight = 60
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.transitionCountry(country: country[indexPath.row])
        
        tableView.deselectRow(at: indexPath, animated: true)
    }


}




//MARK: - Загрузка данных страны

extension ChangeCountryController {
    
   func loadCountry() {
       
       db.collection("Country").getDocuments { QuerySnapshot, Error in
           
           if let error = Error {
               print("Ошибка загрузки данных - \(error)")
           }else {
               if let dataArr = QuerySnapshot?.documents {
                   for doc in dataArr {
                       let data = doc.data()
                       
                       if let name = data["name"] as? String, let serverIP = data["serverIP"] as? String, let password = data["password"] as? String, let sharedKey = data["sharedKey"] as? String, let userName = data["userName"] as? String {
                           
                           self.country.append(Country(name: name, serverIP: serverIP, userName: userName, password: password, sharedKey: sharedKey, selected: false))
                           DispatchQueue.main.async {
                               self.tableView.reloadData()
                           }
                       }else {
                           print("Ошибка преобразования данных")
                       }
                   }
               }
           }
           
           
       }

    }
}
