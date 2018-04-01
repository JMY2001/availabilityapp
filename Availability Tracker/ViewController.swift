//
//  ViewController.swift
//  Availability Tracker
//
//  Created by Abhijith Vemulapati on 2/23/17.
//  Copyright © 2017 Citrus Circuits. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var scoutsTableView: UITableView!
    var scoutsDB : FIRDatabase!
    var scouts = [String : Int]()
    var scoutNames = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        scoutsTableView.delegate = self
        scoutsTableView.dataSource = self
        scoutsDB = FIRDatabase.database()
        let changeStateGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.changeStatus(g:)))
        changeStateGesture.numberOfTapsRequired = 2
        scoutsTableView.addGestureRecognizer(changeStateGesture)
        scoutsDB.reference().child("availability").observe(.value, with: {(snap) in
            self.scouts.removeAll()
            self.scoutNames.removeAll()
            if let values = snap.value as? [String : Int] {
            for (scout, available) in (snap.value as! [String : Int]) {
                self.scoutNames.append(scout)
                self.scouts[scout] = available
            }
            self.scoutsTableView.reloadData()
            }
        })
    }
    @IBAction func addScout() {
        let alert = UIAlertController(title: "Add Scout", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(t) in
            t.placeholder = "Name"
        })
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: {(a) in
            if let textField = alert.textFields?[0] {
                if textField.text != nil {
                    self.scoutsDB.reference().child("availability").child(textField.text!).setValue(0)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        view.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    @IBAction func deleteScouts() {
        let alert = UIAlertController(title: "Delete Scout", message: "Who do you want to delete?", preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "Remove", style: .default, handler: {(byeBoi) in
            self.scoutsDB.reference().child("availability").child(alert.textFields![0].text!).setValue(nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        view.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scoutNames.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.scoutsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let scout = scoutNames[indexPath.row]
        cell.textLabel?.text = scout
        if scouts[scout] == 1 {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func changeStatus(g : UITapGestureRecognizer) {
        let indexPath = scoutsTableView.indexPathForRow(at: g.location(in: scoutsTableView))
        scoutsTableView.cellForRow(at: indexPath!)?.isSelected = false
        var value = 0
        if scouts[scoutNames[(indexPath?.row)!]]! == 0 {
            value = 1
        }
        self.scoutsDB.reference().child("availability").child(self.scoutNames[(indexPath?.row)!]).setValue(value)
    }
}

