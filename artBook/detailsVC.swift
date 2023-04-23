//
//  detailsVC.swift
//  artBook
//
//  Created by Emir Türk on 10.02.2023.
//

import UIKit
import CoreData

class detailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    var chosenPainting = ""
    var chosenPaintingID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if chosenPainting != "" {
            //core data
            saveButton.isHidden = true
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            let idString = chosenPaintingID?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            do {
                let resuls = try context.fetch(fetchRequest)
                if resuls.count > 0 {
                    for result in resuls as! [NSManagedObject] {
                        
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                            }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistText.text = artist
                            }
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                        
                        
                    }
                }
                
            } catch{
                print("error")
            }
            
            
            
            
            
            
        }
        else {
            saveButton.isEnabled = false
        }
        
        
        
        
        
        
        
        // RECOGNİZER
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    
        
    }
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage]  as?  UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true)
    }

    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    @IBAction func saveButtonCliced(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //ATTRİBUTES
        newPainting.setValue(nameText.text, forKey: "name" )
        newPainting.setValue(artistText.text, forKey: "artist")
        
        if let year = Int(yearText.text!){
            newPainting.setValue(year, forKey: "year")
        }
        
        newPainting.setValue(UUID(), forKey: "id")
        
        let data  = imageView.image?.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do{
           try context.save()
            print("saved")
        } catch{
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    

}
