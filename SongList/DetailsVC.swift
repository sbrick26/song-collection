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
