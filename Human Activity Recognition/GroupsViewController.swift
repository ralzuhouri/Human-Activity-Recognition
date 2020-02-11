//
//  GroupsViewController.swift
//  Human Activity Recognition
//
//  Created by Ramy Al Zuhouri on 21/09/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import UIKit

class GroupsViewController: UITableViewController {
	
	var controller:TrainingsController?
	var set:FeatureSet?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
		return 4
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "Vital Signs"
		case 1:
			return "Gyroscope"
		case 2:
			return "Accelerometer"
		case 3:
			return "GPS"
		default:
			return "Unknown Section"
		}
	}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let _ = self.set else { return 0 }
		switch section {
		case 0:
			return 1
		case 1:
			return 8
		case 2:
			return 8
		case 3:
			return 5
		default:
			return 0
		}
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
		
		switch indexPath.section {
		case 0:
			cell.textLabel?.text = "Heart Rate"
			cell.detailTextLabel?.text = "\(set?.heartRate?.numberOfValues ?? 0)"
		case 1:
			switch indexPath.row {
			case 0:
				cell.textLabel?.text = "Roll"
				cell.detailTextLabel?.text = "\(set?.roll?.numberOfValues ?? 0)"
			case 1:
				cell.textLabel?.text = "Pitch"
				cell.detailTextLabel?.text = "\(set?.pitch?.numberOfValues ?? 0)"
			case 2:
				cell.textLabel?.text = "Yaw"
				cell.detailTextLabel?.text = "\(set?.yaw?.numberOfValues ?? 0)"
			case 3:
				cell.textLabel?.text = "Attitude Magnitude"
				cell.detailTextLabel?.text = "\(set?.attitudeMagnitude?.numberOfValues ?? 0)"
			case 4:
				cell.textLabel?.text = "X Rotation Rate"
				cell.detailTextLabel?.text = "\(set?.xRotationRate?.numberOfValues ?? 0)"
			case 5:
				cell.textLabel?.text = "Y Rotation Rate"
				cell.detailTextLabel?.text = "\(set?.yRotationRate?.numberOfValues ?? 0)"
			case 6:
				cell.textLabel?.text = "Z Rotation Rate"
				cell.detailTextLabel?.text = "\(set?.zRotationRate?.numberOfValues ?? 0)"
			case 7:
				cell.textLabel?.text = "Rotation Rate Magnitude"
				cell.detailTextLabel?.text = "\(set?.rotationRateMagnitude?.numberOfValues ?? 0)"
			default:
				break
			}
		case 2:
			switch indexPath.row {
			case 0:
				cell.textLabel?.text = "X Gravity"
				cell.detailTextLabel?.text = "\(set?.xGravity?.numberOfValues ?? 0)"
			case 1:
				cell.textLabel?.text = "Y Gravity"
				cell.detailTextLabel?.text = "\(set?.yGravity?.numberOfValues ?? 0)"
			case 2:
				cell.textLabel?.text = "Z Gravity"
				cell.detailTextLabel?.text = "\(set?.zGravity?.numberOfValues ?? 0)"
			case 3:
				cell.textLabel?.text = "Gravity Magnitude"
				cell.detailTextLabel?.text = "\(set?.gravityMagnitude?.numberOfValues ?? 0)"
			case 4:
				cell.textLabel?.text = "X User Acceleration"
				cell.detailTextLabel?.text = "\(set?.xUserAcceleration?.numberOfValues ?? 0)"
			case 5:
				cell.textLabel?.text = "Y User Acceleration"
				cell.detailTextLabel?.text = "\(set?.yUserAcceleration?.numberOfValues ?? 0)"
			case 6:
				cell.textLabel?.text = "Z User Acceleration"
				cell.detailTextLabel?.text = "\(set?.zUserAcceleration?.numberOfValues ?? 0)"
			case 7:
				cell.textLabel?.text = "User Acceleration Magnitude"
				cell.detailTextLabel?.text = "\(set?.userAccelerationMagnitude?.numberOfValues ?? 0)"
			default:
				break
			}
		case 3:
			switch indexPath.row {
			case 0:
				cell.textLabel?.text = "Latitude"
				cell.detailTextLabel?.text = "\(set?.latitude?.numberOfValues ?? 0)"
			case 1:
				cell.textLabel?.text = "Longitude"
				cell.detailTextLabel?.text = "\(set?.longitude?.numberOfValues ?? 0)"
			case 2:
				cell.textLabel?.text = "Altitude"
				cell.detailTextLabel?.text = "\(set?.altitude?.numberOfValues ?? 0)"
			case 3:
				cell.textLabel?.text = "Course"
				cell.detailTextLabel?.text = "\(set?.course?.numberOfValues ?? 0)"
			case 4:
				cell.textLabel?.text = "Speed"
				cell.detailTextLabel?.text = "\(set?.speed?.numberOfValues ?? 0)"
			default:
				break
			}
		default:
			break
		}

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
		guard let vc = segue.destination as? GroupViewController else { return }
		guard let cell = sender as? UITableViewCell else { return }
		guard let path = self.tableView.indexPath(for: cell) else { return }
		
		let groupNames = [
			["Heart Rate"],
			[
				"Roll",
				"Pitch",
				"Yaw",
				"Attitude Magnitude",
				"X Rotation Rate",
				"Y Rotation Rate",
				"Z Rotation Rate",
				"Rotation Rate Magnitude"
			],
			[
				"X Gravity",
				"Y Gravity",
				"Z Gravity",
				"Gravity Magnitude",
				"X User Acceleration",
				"Y User Acceleration",
				"Z User Acceleration",
				"User Acceleration Magnitude",
			],
			[
				"Latitude",
				"Longitude",
				"Altitude",
				"Course",
				"Speed"
			]
		]
		vc.title = groupNames[path.section][path.row]
		
		let groups = [
			[set?.heartRate],
			[
				set?.roll,
				set?.pitch,
				set?.yaw,
				set?.attitudeMagnitude,
				set?.xRotationRate,
				set?.yRotationRate,
				set?.zRotationRate,
				set?.rotationRateMagnitude
			],
			[
				set?.xGravity,
				set?.yGravity,
				set?.zGravity,
				set?.gravityMagnitude,
				set?.xUserAcceleration,
				set?.yUserAcceleration,
				set?.zUserAcceleration,
				set?.userAccelerationMagnitude
			],
			[
				set?.latitude,
				set?.longitude,
				set?.altitude,
				set?.course,
				set?.speed
			]
		]
		let group = groups[path.section][path.row]
		vc.group = group
		vc.controller = self.controller
    }
}






