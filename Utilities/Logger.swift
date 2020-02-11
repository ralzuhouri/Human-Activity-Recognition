//
//  Logger.swift
//  Human Activity Recognition WatchKit Extension
//
//  Created by Ramy Al Zuhouri on 08/12/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import Foundation

func Log(_ string:String, relativeDate:Date? = nil) {
	DispatchQueue.global(qos: .background).async {
		do {
			var dateString:String
			
			if relativeDate == nil {
				let formatter = DateFormatter()
				formatter.timeStyle = .long
				formatter.dateStyle = .long
				dateString = formatter.string(from: Date())
			} else {
				let time = Date().timeIntervalSince(relativeDate!)
				dateString = "+\(time) s"
			}
			
			let logText = "\(dateString) > \(string)"
			print(logText)
			try Logger.shared.log(logText)
		} catch {
			print("\(error)")
		}
	}
}

class Logger
{
	static private var _sharedInstance:Logger?
	static var shared:Logger {
		if _sharedInstance == nil {
			_sharedInstance = Logger()
		}
		return _sharedInstance!
	}
	
	private init() {}
	
	var contents:String? {
		guard let path = self.url?.path else { return nil }
		do {
			let string = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue) as String
			return string
		} catch {
			print("\(error)")
		}
		return nil
	}
	
	// Doesn't delete a certain number of logs among the most recent ones
	func clearLogs(itemsToKeep:Int) {
		do {
			guard let logs = self.allLogs() else { return }
			var tokens = itemsToKeep
			for log in logs {
				guard log.date != launchDate else { continue }
				if tokens > 0 {
					tokens -= 1
					continue
				}
				try FileManager.default.removeItem(at: log.url)
			}
		} catch {
			print("\(error)")
		}
	}
	
	func clearAllLogs() {
		self.clearLogs(itemsToKeep: 0)
	}
	
	func allLogs() -> [(url:URL,date:Date)]? {
		guard let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first as NSString? else { return nil }
		let manager = FileManager.default
		guard let enumerator = manager.enumerator(atPath: documentDirectory as String) else { return nil }
		let formatter = DateFormatter()
		formatter.timeStyle = .medium
		formatter.dateStyle = .medium
		
		var items:[(url:URL,date:Date)] = []
		for item in enumerator {
			guard var name = item as? String else { continue }
			let path = documentDirectory.appendingPathComponent(name)
			let url = URL(fileURLWithPath: path as String)
			
			
			guard name.hasPrefix("Logfile") && name.hasSuffix(".txt") else { continue }
			guard let prefixRange = name.range(of: "Logfile") else { continue }
			name.removeSubrange(prefixRange)
			
			guard let suffixRange = name.range(of: ".txt") else { continue }
			name.removeSubrange(suffixRange)
			
			guard let date = formatter.date(from: name) else { continue }
			items.append((url:url, date: date))
		}
		
		items.sort { (tuple1, tuple2) -> Bool in
			return tuple1.date > tuple2.date
		}
		
		return items
	}
	
	lazy var launchDate:Date = { return Date() }()
	
	lazy var url:URL? = {
		guard let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first as NSString? else { return nil }
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .medium
		let dateString = formatter.string(from: self.launchDate)
		let path = documentDirectory.appendingPathComponent("Logfile " + dateString + ".txt")
		return URL(fileURLWithPath: path)
	}()
	
	func log(_ string:String) throws {
		guard let url = self.url else { return }
		let path = url.path
		var contents:String?
		
		let manager = FileManager.default
		if !manager.fileExists(atPath: path) {
			manager.createFile(atPath: path, contents: nil, attributes: nil)
		} else {
			contents = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue) as String
		}
		
		if contents == nil {
			contents = string
		} else {
			contents?.append("\n" + string)
		}
		
		try contents?.write(to: url, atomically: true, encoding: .utf8)
	}
}







