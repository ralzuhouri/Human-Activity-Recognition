//
//  DecisionTree.swift
//  Human Activity Recognition
//
//  Created by Ramy Al Zuhouri on 26/01/18.
//  Copyright © 2018 Ramy Al Zuhouri. All rights reserved.
//

import Foundation

fileprivate class IdFactory
{
	private static var _nextId = 0
	
	class func nextId() -> Int {
		defer { _nextId += 1 }
		return _nextId
	}
}

fileprivate protocol Node
{
	var id:Int { get set }
	
	func evaluate(featuresDict:[String:Any]) -> String?
}

fileprivate class BranchNode : Node
{
	var id:Int
	let parameter:String
	let feature:String
	let value:Double
	var rightChild:Node?
	var leftChild:Node?
	
	init(parameter:String, feature:String, value:Double) {
		self.parameter = parameter
		self.feature = feature
		self.value = value
		self.id = IdFactory.nextId()
	}
	
	convenience init?(string:String) {
		do {
			let pattern = "[a-zA-Z]+-[a-zA-Z]+-[a-zA-Z]+[ ][<][=][ ][+-]?[0-9]+[.][0-9]+"
			let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue:0))
			let matches = regex.matches(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, string.lengthOfBytes(using: .utf8)))
			if matches.count > 0 {
				let match = (string as NSString).substring(with: matches.first!.range)
				let components = match.components(separatedBy: " ")
				if components.count == 3 {
					let subcomponents = components[0].components(separatedBy: "-")
					if subcomponents.count == 3 {
						let parameter = subcomponents[0] + "-" + subcomponents[1]
						let feature = subcomponents[2]
						if let value = Double(components[2]) {
							self.init(parameter: parameter, feature: feature, value: value)
							return
						}
					}
				}
			}
		} catch {
			print("Error Initializing BranchNode: \(error)")
			return nil
		}
		
		return nil
	}
	
	func evaluate(featuresDict: [String : Any]) -> String? {
		var featureName:String = self.feature
		if featureName == "IQR" { featureName = "interQuartileRange" }
		guard let dict = featuresDict[parameter] as? [String:Any] else {
			print("Cannot find parameter \(parameter)")
			return nil
		}
		guard let value = dict[featureName] as? Double else {
			print("Cannot find feature name \(featureName)")
			return nil
		}
		
		if value <= self.value {
			return self.leftChild?.evaluate(featuresDict: featuresDict)
		} else {
			return self.rightChild?.evaluate(featuresDict: featuresDict)
		}
	}
	
	func addChild(_ child:Node) {
		if self.leftChild == nil { self.leftChild = child }
		else { self.rightChild = child }
	}
}

fileprivate class LeafNode : Node
{
	var id:Int
	let activity:String
	
	init(activity:String) {
		self.activity = activity
		self.id = IdFactory.nextId()
	}
	
	convenience init?(string:String) {
		do {
			let pattern = "class = [a-zA-Z]+([-\\s][a-zA-Z]+)?"
			let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue:0))
			let matches = regex.matches(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, string.lengthOfBytes(using: .utf8)))
			if matches.count > 0 {
				let match = (string as NSString).substring(with: matches.first!.range)
				let components = match.components(separatedBy: " ")
				if components.count == 3 {
					let activity = components[2]
					self.init(activity: activity)
					return
				} else if components.count == 4 {
					let activity = components[2] + " " + components[3]
					self.init(activity: activity)
					return
				}
			}
		} catch {
			print("Error Initializing LeafNode: \(error)")
		}
		
		return nil
	}
	
	func evaluate(featuresDict: [String : Any]) -> String? {
		return activity
	}
}

fileprivate class Edge
{
	let inNode:Int
	let outNode:Int
	
	init(inNode:Int, outNode:Int) {
		self.inNode = inNode
		self.outNode = outNode
	}
	
	convenience init?(string:String) {
		do {
			let pattern = "[0-9]+[ ]->[ ][0-9]+"
			let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue:0))
			let matches = regex.matches(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, string.lengthOfBytes(using: .utf8)))
			if matches.count > 0 {
				let match = (string as NSString).substring(with: matches.first!.range)
				let components = match.components(separatedBy: " ")
				if components.count == 3 {
					if let inNode = Int(components[0]),  let outNode = Int(components[2]) {
						self.init(inNode: inNode, outNode: outNode)
						return
					}
				}
			}
		} catch {
			print("\(error)")
		}
		
		return nil
	}
}

class DecisionTree
{
	private let root:Node
	private static var sharedInstance:DecisionTree?
	
	class func shared() -> DecisionTree? {
		if sharedInstance == nil {
			guard let path = Bundle.main.path(forResource: "Activities", ofType: "txt") else { return nil }
			let url = URL(fileURLWithPath: path)
			
			do {
				let text = try String(contentsOf: url)
				self.sharedInstance = DecisionTree(string: text)
			} catch {
				print("Error initializing decision tree: \(error)")
			}
		}
		
		return self.sharedInstance
	}
	
	private init?(string:String) {
		let components = string.components(separatedBy: "\n")
		var nodes:[Node] = []
		
		for line in components
		{
			var node:Node?
			if let branch = BranchNode(string: line) {
				node = branch
			} else if let leaf = LeafNode(string: line) {
				node = leaf
			}
			
			if node != nil {
				nodes.append(node!)
				continue
			}
			
			guard let edge = Edge(string: line) else { continue }
			guard let inNode = nodes[edge.inNode] as? BranchNode else { continue }
			let outNode = nodes[edge.outNode]
			
			inNode.addChild(outNode)
		}
		
		guard let root = nodes.first else { return nil }
		self.root = root
	}
	
	func activity(forFeaturesDict featuresDict:[String:Any]) -> String? {
		guard let activity = self.root.evaluate(featuresDict: featuresDict) else {
			print("Cannot determine activity")
			return nil
		}
		
		return activity
	}
}












