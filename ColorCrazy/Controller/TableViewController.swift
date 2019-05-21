//  TableViewController.swift
//  ColorCrazy


import UIKit
import Firebase

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    // firebase
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    // data
    var tabeViewArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // tableview
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        // firebase
        ref = Database.database().reference()
        // data
        updateDBOnChildAdd()
    }
    
    func updateDBOnChildAdd() {
        // create a query
        let query = ref?.child("Scores").queryOrdered(byChild: "score")
        // on childAdded
        query?.observe(.childAdded, with: {(snapshot) in
            // loop through values
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                // get val as Int
                let score = snap.value as! Int
                let absScore = abs(score)
                // get key
                let name = (snap.ref.parent?.key)! as String
                // data for tableview
                let dataString = "\(name): \(absScore)"
                // app to tableView
                self.tabeViewArray.append(dataString)
                // reload tableView array
                self.tableView.reloadData()
            }
        })
    }
    
    // tableview functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tabeViewArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = tabeViewArray[indexPath.row]
        cell?.textLabel?.textAlignment = .center
        cell?.textLabel?.textColor = UIColor(red:0.20, green:0.22, blue:0.59, alpha:1.0)
        cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 32.0)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor(red:0.96, green:0.81, blue:0.27, alpha:0.75)
    }
    
    @IBAction func dismissview(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
