//
//  ViewController.swift
//  ResimDefterim
//
//  Created by Zehra Coşkun on 4.05.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var isimDizisi = [String]()
    var idDizisi = [UUID]()
    var secilenIsimVC = ""
    var secilenIdVC : UUID?
    var favBool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        //ekleme butonu ikonu ve fonksiyonu ekleme
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(eklemeButonuTiklandi))
        //silme butonu ikonu ve fonksiyonu ekleme
        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(silmeButonu))
        
        verileriAl()
    }
    //veri eklendikten sonra anasayfayı güncelleme
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(verileriAl), name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)
    }
    
    
    
    
    @objc func eklemeButonuTiklandi () {
        secilenIsimVC = ""
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    @objc func silmeButonu () {
        
    }
    
    @objc func verileriAl() {
        isimDizisi.removeAll()
        idDizisi.removeAll()
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Resim")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let isim = result.value(forKey: "isim") as? String {
                        isimDizisi.append(isim)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        idDizisi.append(id)
                    }
                }
                tableView.reloadData()
            }
        } catch {
            
        }
    }
    //secilen hücredeki bilgileri detailvc'ye aktarma
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.secilenIsim = secilenIsimVC
            destinationVC.secilenId = secilenIdVC
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenIsimVC = isimDizisi[indexPath.row]
        secilenIdVC = idDizisi[indexPath.row]
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isimDizisi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = isimDizisi[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult> (entityName: "Resim")
            let uuidString = idDizisi[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            context.delete(result)
                            isimDizisi.remove(at: indexPath.row)
                            idDizisi.remove(at: indexPath.row)
                            
                            self.tableView.reloadData()
                            try context.save()
                            break
                        }
                    }
                }
            } catch {print("silerken hata oluştu") }
        }
    }
    //soldan kaydırarak favorilere ekleme/çıkarma
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let title = "Fav"
        self.favBool.toggle()
        let action = UIContextualAction(style: .normal, title: title) { (action, view, completion) in
            let cell = self.tableView.cellForRow(at: indexPath)
            if self.favBool {
                cell?.backgroundColor = .white
            } else {
                cell?.backgroundColor = .systemGreen }
            completion(true)
        }
        action.image = UIImage(systemName: "heart.fill")
        action.backgroundColor = .green
        
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    
}

