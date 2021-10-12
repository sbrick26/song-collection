//
//  ViewController.swift
//  SongList
//
//  Created by Swayam Barik on 10/11/21.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    // create two arrays to hold values for the tableview from Core Data
    var nameArray = [String]()
    var idArray = [UUID]()
    var selectedName = ""
    var selectedID: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
        
        getData()
    }
    // when the view appears after saving, we want to reload w new data, have to getData()
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
    
    @objc func getData() {
        
        // Clear arrays to prevent duplicate entries in table view
        nameArray.removeAll()
        idArray.removeAll()
        
        // Set up app delegate and context
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // Fetch data from Core Data
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Songs")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            // get the results from the fetch request
            let results = try context.fetch(fetchRequest)
            print("Data Fetched")
            
            // results will be an array of the items, have to go through each one
            
            for result in results as! [NSManagedObject] {
                if let name = result.value(forKey: "name") as? String {
                    nameArray.append(name)
                }
                if let id = result.value(forKey: "id") as? UUID {
                    idArray.append(id)
                }
                // after retrieving the data, update the tableView
                
                self.tableView.reloadData()
            }
            
            
        } catch {
            print("Could not fetch data from Core Data")
        }
        
        
    }
    
    @objc func addButtonClicked() {
        // when button is clicked, you want fresh data, so reset the selected
        selectedName = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.chosenName = selectedName
            destinationVC.chosenID = selectedID
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedName = nameArray[indexPath.row]
        selectedID = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel!.text = nameArray[indexPath.row]
        return cell
    }


}

