//
//  InstancesViewController.swift
//  Human Activity Recognition
//
//  Created by Ramy Al Zuhouri on 19/09/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import UIKit

class InstancesViewController: UITableViewController
{
	var controller:TrainingsController?
	var training:Training?
	var _sets:[FeatureSet]?
	var sets:[FeatureSet] {
		if _sets == nil {
			let sortDesc = NSSortDescriptor(key: "sequenceNumber", ascending: true)
			_sets = training?.sets!.sortedArray(using: [sortDesc]) as? [FeatureSet]
		}
		return _sets!
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		guard let training = self.training else { return 0 }
		guard let sets = training.sets else { return 0 }
        return sets.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "instanceCell", for: indexPath)
		let set = self.sets[indexPath.row]
		cell.textLabel?.text = "#\(set.sequenceNumber)"

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
			let set = self.sets[indexPath.row]
			self.controller?.delete(object: set)
			_sets = nil
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showGroups" {
			guard let vc = segue.destination as? GroupsViewController else { return }
			guard let cell = sender as? UITableViewCell else { return }
			guard let path = self.tableView.indexPath(for: cell) else { return }
			let set = self.sets[path.row]
			vc.set = set
			vc.controller = controller
		}
    }

}






