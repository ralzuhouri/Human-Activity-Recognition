//
//  TrainingsViewController.swift
//  Human Activity Recognition
//
//  Created by Ramy Al Zuhouri on 17/09/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import UIKit

class TrainingsViewController: UITableViewController
{
	@IBOutlet weak var exportDataButton: UIButton!
	
	var controller:TrainingsController?
	private var _trainings:[Training]?
	var trainings:[Training] {
		if _trainings == nil {
		 	self.controller = TrainingsController()
			_trainings = self.controller?.trainings
			/*if let trainings = _trainings, exportDataButton != nil {
				exportDataButton.isEnabled = trainings.count > 0
			}*/
		}
		return _trainings!
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		let center = NotificationCenter.default
		center.addObserver(self, selector: #selector(self.didAddTraining(notification:)), name: NSNotification.Name(rawValue: "didAddTraining"), object: nil)
		center.addObserver(self, selector: #selector(self.didEditDataset(notification:)), name: NSNotification.Name(rawValue: "didEditDataset"), object: nil)
		
		center.addObserver(self, selector: #selector(self.didDeleteTraining(notification:)), name: NSNotification.Name(rawValue: "didDeleteTraining"), object: nil)
	}
	
	deinit {
		let center = NotificationCenter.default
		center.removeObserver(self, name: NSNotification.Name(rawValue: "didAddTraining"), object: nil)
		center.removeObserver(self, name: NSNotification.Name(rawValue: "didEditDataset"), object: nil)
		
		center.removeObserver(self, name: NSNotification.Name(rawValue: "didDeleteTraining"), object: nil)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
	
	/*@IBAction func sync(_ sender: Any) {
		let center = NotificationCenter.default
		center.post(name: NSNotification.Name(rawValue: "needsToSyncTrainings"), object: nil)
	}*/
	
	// MARK: - Notifications
	@objc func didAddTraining(notification:Notification) {
		// I experienced an occasional crash when adding a training. This may be because the
		// actual count of the trainings isn't changed when this method is called. 
		//let indexPath = IndexPath(row: 0, section: 0)
		//self.tableView.insertRows(at: [indexPath], with: .fade)
		self.tableView.reloadData()
	}
	
	@objc func didEditDataset(notification:Notification) {
		_trainings = nil
		self.tableView.reloadData()
	}
	
	@objc func didDeleteTraining(notification:Notification) {
		_trainings = nil
		self.tableView.reloadData()
	}

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.trainings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
        let cell = tableView.dequeueReusableCell(withIdentifier: "trainingCell", for: indexPath)
		let training = self.trainings[indexPath.row]
		cell.textLabel?.text = training.activity
		
		let formatter = DateFormatter()
		formatter.timeStyle = .short
		formatter.dateStyle = .short
		let startTime = training.startTime as Date?
		cell.detailTextLabel?.text = formatter.string(from: startTime!)

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
			let training = self.trainings[indexPath.row]
			self.controller?.delete(object: training)
			_trainings = nil
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		var training:Training?
		var path:IndexPath?
		if let cell = sender as? UITableViewCell {
	 		path = self.tableView.indexPath(for: cell)
			if path != nil {
				training = self.trainings[path!.row]
			}
		}
		
		if segue.identifier == "showInstances" {
			
			guard let vc = segue.destination as? InstancesViewController else { return }
			vc.training = training
			vc.controller = controller
		} else if segue.identifier == "showTraining" {
			guard let vc = segue.destination as? TrainingViewController else { return }
			vc.training = training
			vc.controller = controller
		}
    }

}







