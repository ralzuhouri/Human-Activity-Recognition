//
//  InterfaceController.swift
//  Human Activity Recognition WatchKit Extension
//
//  Created by Ramy Al Zuhouri on 02/09/17.
//  Copyright © 2018 Ramy Al Zuhouri. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
	
	override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
		if segueIdentifier == "goToTesting" {
			return SensorsRecorder(activity: "Unknown")
		}
		return nil
	}

}
