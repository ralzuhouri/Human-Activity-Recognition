//
//  GroupViewController.swift
//  Human Activity Recognition
//
//  Created by Ramy Al Zuhouri on 26/09/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController
{
	var controller:TrainingsController?
	var group:FeatureGroup?
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var minLabel: UILabel!
	@IBOutlet weak var maxLabel: UILabel!
	@IBOutlet weak var meanLabel: UILabel!
	@IBOutlet weak var medianLabel: UILabel!
	@IBOutlet weak var deviationLabel: UILabel!
	@IBOutlet weak var varianceLabel: UILabel!
	@IBOutlet weak var skewnessLabel: UILabel!
	@IBOutlet weak var kurtosisLabel: UILabel!
	@IBOutlet weak var interQuartileRangeLabel: UILabel!
	@IBOutlet weak var energyLabel: UILabel!
	@IBOutlet weak var entropyLabel: UILabel!
	
	func format(value:Double) -> String? {
		let formatter1 = NumberFormatter()
		formatter1.numberStyle = .decimal
		formatter1.maximumFractionDigits = 3
		formatter1.minimumFractionDigits = 3
		
		let formatter2 = NumberFormatter()
		formatter2.numberStyle = .scientific
		formatter2.maximumFractionDigits = 3
		formatter2.minimumFractionDigits = 3
		
		if value < 1.0e-3 {
			return formatter2.string(from: value as NSNumber)
		} else {
			return formatter1.string(from: value as NSNumber)
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.titleLabel.text = self.title
		guard let group = self.group else { return }
		
		if let min = group.min as? Double {
			minLabel.text = format(value: min)
		}
		if let max = group.max as? Double {
			maxLabel.text = format(value: max)
		}
		if let mean = group.mean as? Double {
			meanLabel.text = format(value: mean)
		}
		if let median = group.median as? Double {
			medianLabel.text = format(value: median)
		}
		if let deviation = group.deviation as? Double {
			deviationLabel.text = format(value: deviation)
		}
		if let variance = group.variance as? Double {
			varianceLabel.text = format(value: variance)
		}
		if let skewness = group.skewness as? Double {
			skewnessLabel.text = format(value: skewness)
		}
		if let kurtosis = group.kurtosis as? Double {
			kurtosisLabel.text = format(value: kurtosis)
		}
		if let interQuartileRange = group.interQuartileRange as? Double {
			interQuartileRangeLabel.text = format(value: interQuartileRange)
		}
		if let energy = group.energy as? Double {
			energyLabel.text = format(value: energy)
		}
		if let entropy = group.entropy as? Double {
			entropyLabel.text = format(value: entropy)
		}
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







