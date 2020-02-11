//
//  HistorySetClassifier.swift
//  Human Activity Recognition
//
//  Created by Ramy Al Zuhouri on 31/01/18.
//  Copyright © 2018 Ramy Al Zuhouri. All rights reserved.
//

import Foundation

protocol HistorySetDelegate : NSObjectProtocol
{
	func historySet(_ historySet:HistorySet, didTransitionFromActivity fromActivity:String, toActivity:String)
}

class HistorySet
{
	private var history:Queue<String>
	var accuracy:Double = 0.0
	public private(set) var activity:String
	weak var delegate:HistorySetDelegate?
	
	private func setActivity() {
		var node = self.history.head
		var dict:[String:Int] = [:]
		let previousActivity = self.activity
		
		repeat {
			guard let currentNode = node else { continue }
			var count = dict[currentNode.value, default: 0]
			count += 1
			dict[currentNode.value] = count
			node = currentNode.previous
		} while node != nil
		
		let result = dict.reduce((key: "Unknown", value: 0), { (result, currentValue) in
			if currentValue.value > result.value { return currentValue }
			return result
		})
		
		self.accuracy = Double(result.value) / Double(self.history.count)
		
		if self.accuracy > 0.5 {
			self.activity = result.key
		} else {
			self.activity = "Unknown"
		}
		
		if previousActivity != self.activity {
			self.delegate?.historySet(self, didTransitionFromActivity: previousActivity, toActivity: self.activity)
		}
	}
	
	func insert(activity:String) {
		let _ = self.history.pop()
		self.history.pushBack(activity)
		self.setActivity()
	}
	
	var size:Int {
		return self.history.count
	}
	
	init(historySize:Int) {
		self.history = Queue<String>()
		for _ in 0..<historySize {
			self.history.pushBack("Unknown")
		}
		
		self.activity = "Unknown"
	}
}





