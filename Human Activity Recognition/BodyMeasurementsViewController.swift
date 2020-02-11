//
//  BodyMeasurementsViewController.swift
//  Human Activity Recognition
//
//  Created by Ramy Al Zuhouri on 14/11/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import UIKit
import HealthKit

class BodyMeasurementsViewController: UIViewController
{
	var training:Training?
	var controller:TrainingsController?
	@IBOutlet weak var weightLabel: UILabel!
	@IBOutlet weak var heightLabel: UILabel!
	@IBOutlet weak var ageLabel: UILabel!
	@IBOutlet weak var genderLabel: UILabel!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		if let weight = self.training?.weight {
			self.weightLabel.text = "\(weight) kg"
		}
		if let height = self.training?.height {
			self.heightLabel.text = "\(height) m"
		}
		if let age = self.training?.age {
			self.ageLabel.text = "\(age)"
		}
		if let gender = self.training?.gender as? Int, let biologicalSex = HKBiologicalSex(rawValue: gender) {
			switch biologicalSex {
			case .female:
				genderLabel.text = "Female"
			case .male:
				genderLabel.text = "Male"
			case .other:
				genderLabel.text = "Other"
			case .notSet:
				genderLabel.text = "Not Set"
			}
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}







