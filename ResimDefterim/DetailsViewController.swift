//
//  DetailsViewController.swift
//  ResimDefterim
//
//  Created by Zehra Coşkun on 4.05.2023.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var isimTextField: UITextField!
    @IBOutlet weak var gorselImage: UIImageView!
    @IBOutlet weak var cizerTextField: UITextField!
    @IBOutlet weak var kaydetButonu: UIButton!
    
    var secilenIsim = ""
    var secilenId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ekleme sayfası mı detay sayfası mı açlıcak kontrolü
        if secilenIsim != "" {
            kaydetButonu.isHidden = true
            if let uuidString = secilenId?.uuidString {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Resim")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
         //tiplerini kontrol ederek detay sayfasını gösterme
                do {
                    let results = try context.fetch(fetchRequest)
                    if results.count > 0 {
                        for result in results as! [NSManagedObject] {
                            if let isim = result.value(forKey: "isim") as? String {
                                isimTextField.text = isim
                            }
                            if let cizer = result.value(forKey: "cizer") as? String {
                                cizerTextField.text = cizer
                            }
                            if let gorselData = result.value(forKey: "gorsel") as? Data {
                                let image = UIImage(data: gorselData)
                                gorselImage.image = image
                            }
                            
                        }
                    }
                } catch {
                    print("detail view hatası")
                }
            }
            
        } else {
            kaydetButonu.isHidden = false
            kaydetButonu.isEnabled = false
            isimTextField.text = ""
            cizerTextField.text = ""
        }
        
        
        
        
        
        //boş bir yere tıklayınca klavyeyi kapatma -klavye.1
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeyiKapat))
        view.addGestureRecognizer(gestureRecognizer)
        
        //göresele tıklayınca albümü açıp seçme ve kaydetip resim seçiciyi kapatma -resim.1
        gorselImage.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gorselSec))
        gorselImage.addGestureRecognizer(imageGestureRecognizer)
    }
    //albümü açıp resim seçme -resim.2
    @objc func gorselSec() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    //seçilen resmi kaydetip albümü kapatma -resim.3
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        gorselImage.image = info[.editedImage] as? UIImage
        kaydetButonu.isEnabled = true
        self.dismiss(animated: true)
    }
    
    //boş bir yere tıklayınca klavyeyi kapatma -klavye.2
    @objc func klavyeyiKapat () {
        view.endEditing(true)
    }
    
    @IBAction func kaydeteBasildi(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let resim = NSEntityDescription.insertNewObject(forEntityName: "Resim", into: context)
        
        resim.setValue(isimTextField.text!, forKey: "isim")
        resim.setValue(cizerTextField.text!, forKey: "cizer")
        resim.setValue(UUID(), forKey: "id")
        let data = gorselImage.image!.jpegData(compressionQuality: 0.5)
        resim.setValue(data, forKey: "gorsel")
        
        do {
            try context.save()
        } catch { print("veriyi kaydederken hata oluştu")}
        
        //veri girişi olduğunu anasayfaya haber verme
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
}
