//
//  DetailsVC.swift
//  SongList
//
//  Created by Swayam Barik on 10/11/21.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var genreText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var chosenName = ""
    var chosenID: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Gesture Recognizers
        
        // hide keyboard when text field is not in use
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        // ability to touch on image to upload image of choice
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
        // Do any additional setup after loading the view.
        
        // Check whether we are adding or displaying through chosenName value "" = adding
        
        if chosenName != "" {
            // hide save button later TODO: Penis
            // this means we got something, and want to display, so find it bro
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Songs")
            fetchRequest.returnsObjectsAsFaults = false
            
            let idString = chosenID?.uuidString
            
            // find something in Core Data with the same ID
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 { //double check if there was something found, but with UUID should be unique so maybe not necessary
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        if let genre = result.value(forKey: "genre") as? String {
                            genreText.text = genre
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
                
            } catch {
                print("Did not fetch from tableview/Core Data")
            }
            
        }
        else {
            // unhide button here later
            nameText.text = ""
            artistText.text = ""
            genreText.text = ""
            imageView.image = UIImage(named: "saveimage")
        }
    }
    
    @objc func selectImage() {
        //allows access to user library
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    //after selecting, need to set the image to something we have and dismiss the UIImagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        // reach app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newSongInfo = NSEntityDescription.insertNewObject(forEntityName: "Songs", into: context)
        
        // go through the attributes and set them
        
        newSongInfo.setValue(nameText.text, forKey: "name")
        newSongInfo.setValue(artistText.text, forKey: "artist")
        newSongInfo.setValue(genreText.text, forKey: "genre")
        newSongInfo.setValue(UUID(), forKey: "id")
        
        // convert image to data
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        newSongInfo.setValue(data, forKey: "image")
        
        // save data to Core Data
        
        do {
            try context.save()
            print("Item saved to Core Data")
        } catch {
            // error if save did not occur
            print("Item was not saved to Core Data")
        }
        
        // Need to send newData to app through Notification Center.default
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        // pop the view from the screen
        self.navigationController?.popViewController(animated: true)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
