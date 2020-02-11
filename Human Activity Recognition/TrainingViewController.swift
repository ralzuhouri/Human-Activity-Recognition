//
//  TrainingViewController.swift
//  Human Activity Recognition
//
//  Created by Ramy Al Zuhouri on 28/09/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import UIKit

class TrainingViewController: UIViewController
{
	@IBOutlet weak var activityLabel:UILabel!
	@IBOutlet weak var startTimeLabel:UILabel!
	@IBOutlet weak var endTimeLabel:UILabel!
	@IBOutlet weak var numberOfInstancesLabel:UILabel!
	@IBOutlet weak var wristLocationLabel: UILabel!
	@IBOutlet weak var crownOrientationLabel: UILabel!
	@IBOutlet weak var overlappingWindowsLabel: UILabel!
	@IBOutlet weak var windowSizeLabel: UILabel!
	@IBOutlet weak var samplingFrequencyLabel: UILabel!
	var controller:TrainingsController?
	var training:Training?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .medium
		
		activityLabel.text = training?.activity
		if let startTime = training?.startTime as Date? {
			startTimeLabel.text = formatter.string(from: startTime)
		}
		if let endTime = training?.endTime as Date? {
			endTimeLabel.text = formatter.string(from: endTime)
		}
		if let count = training?.sets?.count {
			numberOfInstancesLabel.text = "\(count)"
		}
		
		if let wristLocation = training?.wristLocation {
			switch wristLocation {
			case 0:
				wristLocationLabel.text = "Left"
			case 1:
				wristLocationLabel.text = "Right"
			default:
				break
			}
		}
		if let crownOrientation = training?.crownOrientation {
			switch crownOrientation {
			case 0:
				crownOrientationLabel.text = "Left"
			case 1:
				crownOrientationLabel.text = "Right"
			default:
				break
			}
		}
		
		if let overlappingWindows = training?.overlappingWindows {
			switch overlappingWindows {
			case true:
				self.overlappingWindowsLabel.text = "Yes"
			case false:
				self.overlappingWindowsLabel.text = "No"
			}
		}
		
		if let windowSize = training?.windowSize {
			self.windowSizeLabel.text = "\(windowSize)s"
		}
		
		if let samplingFrequency = training?.samplingFrequency {
			self.samplingFrequencyLabel.text = "\(samplingFrequency)"
		}
    }

	
	@IBAction func deleteTraining(_ sender: Any) {
		self.controller?.delete(object: self.training!)
		
		let center = NotificationCenter.default
		center.post(name: NSNotification.Name(rawValue:"didDeleteTraining"), object: nil, userInfo: ["training":self.training!])
		
		self.navigationController?.popViewController(animated: true)
	}
	
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		if segue.identifier == "showInstances" {
			guard let vc = segue.destination as? InstancesViewController else { return }
			vc.controller = self.controller
			vc.training = self.training
		} else if segue.identifier == "showBodyMeasurements" {
			guard let vc = segue.destination as? BodyMeasurementsViewController else { return }
			vc.controller = self.controller
			vc.training = self.training
		}
    }
}







