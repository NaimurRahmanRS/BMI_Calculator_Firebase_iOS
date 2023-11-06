//
//  ViewController.swift
//  1907031
//
//  Created by kuet on 11/10/23.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    
    @IBOutlet weak var Height: UITextField!
    @IBOutlet weak var Calculate: UIButton!
    @IBOutlet weak var Weight: UITextField!
    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var Result: UITextField!
    @IBOutlet weak var ShowHeight: UITextField!
    @IBOutlet weak var ShowWeight: UITextField!
    @IBOutlet weak var DeleteMsg: UITextField!
    @IBOutlet weak var Show: UIButton!
    @IBOutlet weak var ShowResult: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func Button(_ sender: Any) {
        let h = Height.text ?? "1"
            let w = Weight.text ?? "1"
            let num1 = Float(h) ?? 1
            let num2 = Float(w) ?? 1
            let bmi = num2 / (num1 * num1)
            let roundedNum1 = String(format: "%.2f", num1)
            let roundedNum2 = String(format: "%.2f", num2)
            let roundedBmi = String(format: "%.2f", bmi)
            Result.text = roundedBmi
            
            if (bmi >= 18.5 && bmi <= 25.0) {
                Image.image = UIImage(imageLiteralResourceName: "thumbsup")
            } else {
                Image.image = UIImage(imageLiteralResourceName: "thumbsdown")
            }
            
            // Save data to Firebase when Calculate button is clicked
            saveDataToFirebase(num1: roundedNum1, num2: roundedNum2, bmi: roundedBmi)
    }
    
    @IBAction func ShowButton(_ sender: Any) {
        // Create a reference to your Firebase database
           let ref = Database.database().reference().child("entries")

           // Query the data to get the last entered node
           ref.queryOrderedByKey().queryLimited(toLast: 1).observeSingleEvent(of: .value) { (snapshot) in
               if let lastEntry = snapshot.children.allObjects.first as? DataSnapshot,
                  let entryData = lastEntry.value as? [String: Any] {
                   if let num1 = entryData["num1"] as? String,
                      let num2 = entryData["num2"] as? String,
                      let bmi = entryData["bmi"] as? String {
                       self.ShowHeight.text = num1
                       self.ShowWeight.text = num2
                       self.ShowResult.text = bmi
                   } else {
                       print("Error parsing data from Firebase.")
                   }
               } else {
                   print("No entries found in Firebase.")
               }
           }
    }
    
    @IBAction func DeleteButton(_ sender: Any) {
        // Create a reference to your Firebase database
            let ref = Database.database().reference().child("entries")

            // Query the data to get the last entered node
            ref.queryOrderedByKey().queryLimited(toLast: 1).observeSingleEvent(of: .value) { (snapshot) in
                if let lastEntry = snapshot.children.allObjects.first as? DataSnapshot {
                    let entryKey = lastEntry.key
                    let entryRef = ref.child(entryKey)
                    
                    entryRef.removeValue { (error, _) in
                        if let error = error {
                            print("Error deleting data from Firebase: \(error.localizedDescription)")
                            self.DeleteMsg.text = "Deletion failed"
                        } else {
                            print("Data deleted from Firebase successfully!")
                            self.DeleteMsg.text = "Deleted Successfully"
                        }
                    }
                } else {
                    print("No entries found in Firebase.")
                }
            }
    }
    
    func saveDataToFirebase(num1: String, num2: String, bmi: String) {
        // Create a reference to your Firebase database
        let ref = Database.database().reference()
        
        // Generate a unique key for each entry (e.g., using a timestamp)
        let timestamp = Int(Date().timeIntervalSince1970)
        let entryRef = ref.child("entries").child(String(timestamp))
        
        // Create a dictionary with the data you want to store
        let entryData: [String: Any] = [
            "num1": num1,
            "num2": num2,
            "bmi": bmi
        ]
        
        // Set the data at the reference location
        entryRef.setValue(entryData) { (error, _) in
            if let error = error {
                print("Error saving data to Firebase: \(error.localizedDescription)")
            } else {
                print("Data saved to Firebase successfully!")
            }
        }
    }
    
    
}

