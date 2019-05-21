//  StartViewController.swift
//  ColorCrazy

import UIKit
import Firebase

class StartViewController: UIViewController {

    @IBOutlet weak var scoreLabel: UILabel!
    var globalScore = Int()
    var ref: DatabaseReference!
    var name = "" {didSet {ref?.child("Scores").child(name).child("score").setValue(globalScore)}}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
    }
    
    // Play Button
    @IBAction func onPlayButtonPress(_ sender: Any) {
        // Transition to next controller
        performSegue(withIdentifier: "segue", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        // Save the score in NSUSERdefaults
        if let gameScore = defaults.value(forKey: "score"){
            let score = gameScore as! Int
            globalScore = -score
            scoreLabel.text = "Score: \(String(score))"
        }
    }

    // if user would like to add their score
    @IBAction func addToFirebaseDB(_ sender: Any) {
        showAlertWithTextField()
    }
    
    func showAlertWithTextField() {
        // present a popup to get their name
        let alertController = UIAlertController(title: "Enter your name", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Add", style: .default) { (_) in
            if let txtField = alertController.textFields?.first, let text = txtField.text {
                self.name = text
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
